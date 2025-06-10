import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:application/models/post_2.dart';
import 'package:application/models/bid.dart';
import 'package:application/API_Service/api.dart';
import 'package:hive/hive.dart';
import '../../../API_Service/AppConfig.dart';

// WebSocket models
class BidUpdateDTO {
  final int postId;
  final double finalPrice;
  final String userName;
  final String timestamp;

  BidUpdateDTO({
    required this.postId,
    required this.finalPrice,
    required this.userName,
    required this.timestamp,
  });

  factory BidUpdateDTO.fromJson(Map<String, dynamic> json) {
    return BidUpdateDTO(
      postId: json['postId'] ?? 0,
      finalPrice: (json['finalPrice'] ?? 0.0).toDouble(),
      userName: json['userName'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class TimerNotification {
  final int postId;
  final String event;
  final int remainingSeconds;
  final String timestamp;
  final String? message;

  TimerNotification({
    required this.postId,
    required this.event,
    required this.remainingSeconds,
    required this.timestamp,
    this.message,
  });

  factory TimerNotification.fromJson(Map<String, dynamic> json) {
    return TimerNotification(
      postId: json['postId'] ?? 0,
      event: json['event'] ?? '',
      remainingSeconds: json['remainingSeconds'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      message: json['message'],
    );
  }
}

class AuctionProvider with ChangeNotifier {
  final int auctionId;
  Post selectedPost;
  List<Bid> bids = [];

  bool isWebSocketConnected = false;
  bool isTimerActive = false;
  bool isCurrentPostActive = false;
  String auctionStatus = "WAITING";

  // NEW: Delay phase properties
  bool isInDelayPhase = false;
  int delaySecondsRemaining = 0;
  String? nextItemTitle;
  bool isTransitioning = false; // NEW: Loading state for transition

  Duration timeLeft = Duration.zero;
  int remainingSeconds = 0;
  DateTime? lastServerUpdate;

  // Add state for recent activity
  bool hasRecentBidActivity = false;
  DateTime? lastBidTime;

  StompClient? _stompClient;
  Timer? _timer;
  Timer? _delayTimer; // NEW: Timer for delay countdown
  Timer? _reconnectionTimer;
  Timer? _activityResetTimer;
  int _reconnectionAttempts = 0;
  static const int maxReconnectionAttempts = 5;

  // Flag to signal UI to navigate after auction sequence completion
  bool _shouldNavigateAfterSequenceCompletion = false;
  bool get shouldNavigateAfterSequenceCompletion => _shouldNavigateAfterSequenceCompletion;

  // Method for UI to call after handling navigation
  void navigationToNextAuctionHandled() {
    _shouldNavigateAfterSequenceCompletion = false;
    // No need to notifyListeners here as the screen is likely changing.
  }

  AuctionProvider({required this.selectedPost, required this.auctionId}) {
    // Initialize bids from the post's auctionBidTrackers
    bids = List.from(selectedPost.bids ?? []);

    // If bids exist, set the last bid time
    if (bids.isNotEmpty) {
      bids.sort((a, b) => b.time.compareTo(a.time)); // Sort by most recent first
      lastBidTime = bids.first.time;
    }

    print("=== AUCTION PROVIDER INITIALIZATION ===");
    selectedPost.debugPrint();
    print("Initial bids count: ${bids.length}");
    print("Initial current price: $currentPrice");
    print("Initial next minimum bid: $nextMinimumBid");
    print("Has existing bids: ${bids.isNotEmpty}");
    if (bids.isNotEmpty) {
      print("Latest bid: ${bids.first.amount} by ${bids.first.userName}");
    }

    _initializeAuctionState();
    _initializeWebSocket();
    _startLocalTimer();
  }

  double get currentPrice {
    // Priority: finalPrice > currentBid > startPrice
    if (selectedPost.finalPrice != null && selectedPost.finalPrice! > 0) {
      return selectedPost.finalPrice!;
    } else if (selectedPost.currentBid != null && selectedPost.currentBid! > 0) {
      return selectedPost.currentBid!;
    } else {
      return selectedPost.startPrice;
    }
  }
  double get nextMinimumBid => currentPrice + selectedPost.bidStep;

  /// Get the current highest bid amount for display
  double getCurrentDisplayPrice() {
    return currentPrice;
  }

  /// Get the minimum bid required
  double getMinimumBid() {
    return currentPrice + selectedPost.bidStep;
  }

  /// Get unique bidders count
  int get uniqueBiddersCount => bids.map((bid) => bid.userName).toSet().length;

  /// Get total bids count
  int get totalBidsCount => bids.length;

  /// Check if there's recent bidding activity
  bool get hasRecentActivity => hasRecentBidActivity;

  /// Get time since last bid
  String get timeSinceLastBid {
    if (lastBidTime == null) return "No bids yet";
    final difference = DateTime.now().difference(lastBidTime!);
    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else {
      return "${difference.inHours}h ago";
    }
  }

  // NEW: Get delay status text
  String get delayStatusText {
    if (!isInDelayPhase) return "";
    if (auctionStatus == "AUCTION_SEQUENCE_COMPLETED") {
      return "Auction ended. Returning soon... (${delaySecondsRemaining}s)";
    }
    if (nextItemTitle != null) {
      return "Next: $nextItemTitle (in ${delaySecondsRemaining}s)";
    }
    return "Preparing next auction... (${delaySecondsRemaining}s)";
  }

  void _initializeAuctionState() {
    switch (selectedPost.status) {
      case 'IN_PROGRESS':
        auctionStatus = "ACTIVE";
        isCurrentPostActive = true;
        isTimerActive = true;
        remainingSeconds = 30; // Default, will be updated by server
        break;
      case 'COMPLETED':
        auctionStatus = "COMPLETED";
        isCurrentPostActive = false;
        isTimerActive = false;
        break;
      default:
        auctionStatus = "WAITING";
        isCurrentPostActive = false;
        isTimerActive = false;
        break;
    }
    _checkCurrentActivePost();
  }

  Future<void> _checkCurrentActivePost() async {
    try {
      final result = await ApiService.getCurrentActivePost(auctionId);
      if (result != null && !_isDisposed) {
        _handleActivePostResponse(result);
      }
    } catch (e) {
      print('Error checking current active post: $e');
    }
  }

  void _handleActivePostResponse(Map<String, dynamic> result) {
    final activePostData = result['activePost'];
    final seconds = result['remainingSeconds'] ?? 0;
    final timerIsActive = result['isTimerActive'] ?? false;

    if (activePostData != null) {
      final activePostId = activePostData['id'];
      isCurrentPostActive = activePostId == selectedPost.id;

      if (isCurrentPostActive) {
        // If the current post is active, update its details
        // This assumes activePostData contains fields compatible with Post.fromJson or similar
        // For simplicity, we'll just use the ID check for now and rely on WebSocket for full updates.
        // selectedPost = Post.fromJson(activePostData); // Potentially update selectedPost
      }
    } else {
      isCurrentPostActive = false;
    }

    isTimerActive = isCurrentPostActive && timerIsActive;
    remainingSeconds = seconds;
    lastServerUpdate = DateTime.now();

    if (isCurrentPostActive && isTimerActive) {
      auctionStatus = "ACTIVE";
      timeLeft = Duration(seconds: remainingSeconds);
      if (selectedPost.status != 'IN_PROGRESS') {
        selectedPost = selectedPost.copyWith(status: 'IN_PROGRESS');
      }
    } else if (selectedPost.status == 'COMPLETED') {
      auctionStatus = "COMPLETED";
    } else if (!isCurrentPostActive && auctionStatus != "AUCTION_SEQUENCE_COMPLETED") {
      // If no post is active and sequence is not completed, it's waiting
      auctionStatus = "WAITING";
    }


    print('Updated state from _checkCurrentActivePost: status=$auctionStatus, active=$isCurrentPostActive, timer=$isTimerActive, remaining=$remainingSeconds');
    notifyListeners();
  }

  void _initializeWebSocket() async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      if (token == null) {
        print('❌ No authentication token found for WebSocket');
        return;
      }

      _stompClient = StompClient(
        config: StompConfig(
          url: AppConfig.webSocketUrl,
          onConnect: _onWebSocketConnected,
          onWebSocketError: _onWebSocketError,
          onStompError: _onStompError,
          onDisconnect: _onWebSocketDisconnected,
          webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
          stompConnectHeaders: {'Authorization': 'Bearer $token'},
          heartbeatIncoming: Duration(seconds: 20),
          heartbeatOutgoing: Duration(seconds: 20),
          connectionTimeout: Duration(seconds: 10),
        ),
      );

      print('🚀 Connecting to WebSocket...');
      _stompClient!.activate();
    } catch (e) {
      print('❌ WebSocket initialization error: $e');
      _scheduleReconnection();
    }
  }

  void _onWebSocketConnected(StompFrame frame) {
    print('✅ WebSocket Connected');
    isWebSocketConnected = true;
    _reconnectionAttempts = 0;
    _cancelReconnectionTimer();
    _setupSubscriptions();
    _checkCurrentActivePost(); // Sync state upon connection
    notifyListeners();
  }

  void _onWebSocketError(dynamic error) {
    print('❌ WebSocket Error: $error');
    isWebSocketConnected = false;
    _scheduleReconnection();
    notifyListeners();
  }

  void _onStompError(StompFrame frame) {
    print('❌ Stomp Error: ${frame.body}');
    isWebSocketConnected = false;
    _scheduleReconnection();
    notifyListeners();
  }

  void _onWebSocketDisconnected(StompFrame frame) {
    print('🔌 WebSocket Disconnected');
    isWebSocketConnected = false;
    _scheduleReconnection();
    notifyListeners();
  }

  void _setupSubscriptions() {
    if (_stompClient == null || !isWebSocketConnected || _isDisposed) return;

    try {
      print('🔧 Setting up WebSocket subscriptions for post ${selectedPost.id} and auction $auctionId...');

      // Unsubscribe from old post-specific topics if any (important for _transitionToNextPost)
      // This requires storing subscription IDs, which adds complexity.
      // For now, we assume StompClient handles resubscribing to the same topic gracefully
      // or that _transitionToNextPost will call deactivate/activate or manage subscriptions.

      // Subscribe to post-specific bid updates
      final bidTopic = '/topic/auction/${selectedPost.id}/bids';
      print('📡 Subscribing to bid updates: $bidTopic');
      _stompClient!.subscribe(
        destination: bidTopic,
        callback: _onBidUpdate,
      );

      // Subscribe to post-specific timer updates
      final timerTopic = '/topic/auction/${selectedPost.id}/timer';
      print('📡 Subscribing to timer updates: $timerTopic');
      _stompClient!.subscribe(
        destination: timerTopic,
        callback: _onTimerUpdate,
      );

      // Subscribe to auction-wide updates
      final auctionTopic = '/topic/auction/$auctionId';
      print('📡 Subscribing to general auction updates: $auctionTopic');
      _stompClient!.subscribe(
        destination: auctionTopic,
        callback: _onAuctionUpdate, // This handles general messages, including bids if sent here
      );

      print('✅ All WebSocket subscriptions set up successfully for post ${selectedPost.id}');
    } catch (e) {
      print('❌ Error setting up subscriptions: $e');
    }
  }

  void _scheduleReconnection() {
    if (_reconnectionAttempts >= maxReconnectionAttempts || _isDisposed) {
      print('❌ Max reconnection attempts reached or provider disposed.');
      return;
    }

    _cancelReconnectionTimer();

    final delay = Duration(seconds: 2 * (_reconnectionAttempts + 1));
    print('🔄 Scheduling reconnection in ${delay.inSeconds} seconds (attempt ${_reconnectionAttempts + 1})');

    _reconnectionTimer = Timer(delay, () {
      if (!isWebSocketConnected && !_isDisposed) {
        _reconnectionAttempts++;
        _initializeWebSocket();
      }
    });
  }

  void _cancelReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  void _onBidUpdate(StompFrame frame) {
    if (frame.body == null || _isDisposed) return;

    try {
      final data = json.decode(frame.body!);
      print('💰 Processing dedicated bid update: $data');

      final bidUpdate = BidUpdateDTO.fromJson(data);

      if (bidUpdate.postId == selectedPost.id && bidUpdate.finalPrice > 0) {
        print('💰 Received dedicated bid update for current post ${selectedPost.id}: ${bidUpdate.finalPrice} by ${bidUpdate.userName}');
        _updatePostWithNewBid(bidUpdate.finalPrice, bidUpdate.userName);
      }
    } catch (e) {
      print('❌ Error processing dedicated bid update: $e');
      print('Raw frame body: ${frame.body}');
    }
  }

  void _updatePostWithNewBid(double newPrice, String userName) {
    // Create new bid and add to the beginning of the list
    final newBid = Bid(
      // Assuming Bid model has a way to be created, or adjust as needed
      userId: DateTime.now().millisecondsSinceEpoch, // Placeholder for actual user ID if available
      amount: newPrice,
      userName: userName,
      time: DateTime.parse(DateTime.now().toIso8601String()), // Consistent time
    );

    // Keep only the latest bid per user, add new bid at the top
    bids.removeWhere((bid) => bid.userName == userName);
    bids.insert(0, newBid); // Add to the beginning

    selectedPost = selectedPost.copyWith(
      finalPrice: newPrice,
      currentBid: newPrice, // Ensure currentBid also reflects the latest price
      numberOfBidders: uniqueBiddersCount,
      bids: List.from(bids), // Pass a new list instance
    );

    hasRecentBidActivity = true;
    lastBidTime = newBid.time;

    _activityResetTimer?.cancel();
    _activityResetTimer = Timer(Duration(seconds: 3), () {
      if (!_isDisposed) {
        hasRecentBidActivity = false;
        notifyListeners();
      }
    });

    print('✅ Post ${selectedPost.id} updated with new bid. Final Price: ${selectedPost.finalPrice}, Bids count: ${bids.length}');
    notifyListeners();
  }


  void _onTimerUpdate(StompFrame frame) {
    if (frame.body == null || _isDisposed) return;

    try {
      final data = json.decode(frame.body!);
      final timerNotification = TimerNotification.fromJson(data);

      print('⏰ Timer event received: ${timerNotification.event} for post ${timerNotification.postId}, remaining: ${timerNotification.remainingSeconds}s, Message: ${timerNotification.message}');

      // Handle events for the current post or auction-wide events
      if (timerNotification.postId == selectedPost.id || timerNotification.postId == 0 || timerNotification.postId == auctionId) {

        bool stateChanged = false;

        switch (timerNotification.event) {
          case 'POST_STARTED':
          case 'TIMER_STARTED':
            if (isInDelayPhase && timerNotification.postId != selectedPost.id && timerNotification.postId != 0) {
              // This is a new post starting after a delay
              _transitionToNextPost(timerNotification.postId).then((_) {
                if (!_isDisposed) {
                  auctionStatus = "ACTIVE";
                  isCurrentPostActive = true;
                  isTimerActive = true;
                  isInDelayPhase = false;
                  _stopDelayTimer();
                  _updateTimer(timerNotification.remainingSeconds);
                  selectedPost = selectedPost.copyWith(status: 'IN_PROGRESS');
                  notifyListeners(); // Notify after transition and state update
                }
              });
              return; // Transition handles its own notification
            }
            // If it's for the current post or a general start
            if (timerNotification.postId == selectedPost.id || timerNotification.postId == 0){
              auctionStatus = "ACTIVE";
              isCurrentPostActive = true;
              isTimerActive = true;
              isInDelayPhase = false;
              _stopDelayTimer();
              _updateTimer(timerNotification.remainingSeconds);
              if (selectedPost.status != 'IN_PROGRESS') {
                selectedPost = selectedPost.copyWith(status: 'IN_PROGRESS');
              }
              stateChanged = true;
            }
            break;

          case 'TIMER_RESTARTED':
            if (isCurrentPostActive && (timerNotification.postId == selectedPost.id || timerNotification.postId == 0)) {
              isTimerActive = true;
              _updateTimer(timerNotification.remainingSeconds);
              stateChanged = true;
            }
            break;

          case 'TIMER_STOPPED':
            if (isCurrentPostActive && (timerNotification.postId == selectedPost.id || timerNotification.postId == 0)) {
              isTimerActive = false;
              timeLeft = Duration.zero;
              stateChanged = true;
            }
            break;

          case 'TIMER_EXPIRED':
            if (timerNotification.postId == selectedPost.id || timerNotification.postId == 0) {
              auctionStatus = "COMPLETED";
              isCurrentPostActive = false;
              isTimerActive = false;
              timeLeft = Duration.zero;
              if (selectedPost.status != 'COMPLETED') {
                selectedPost = selectedPost.copyWith(status: 'COMPLETED');
              }

              // Set delay phase even if we don't receive AUCTION_DELAY_STARTED
              isInDelayPhase = true;
              delaySecondsRemaining = 10; // Default to 10 seconds
              _startDelayTimer();

              // Set up a fallback timer that will trigger transition if we don't
              // receive AUCTION_DELAY_COMPLETED within 12 seconds
              Timer(Duration(seconds: 12), () {
                if (!_isDisposed && isInDelayPhase) {
                  print('⚠️ Fallback timer triggered - AUCTION_DELAY_COMPLETED not received');
                  _fetchAndTransitionToNextPost();
                }
              });

              stateChanged = true;
            }
            break;

          case 'AUCTION_DELAY_STARTED':
          // This delay could be for next item or end of auction sequence
            auctionStatus = "DELAY"; // General delay status
            isInDelayPhase = true;
            delaySecondsRemaining = timerNotification.remainingSeconds;
            nextItemTitle = null; // Reset
            if (timerNotification.message != null) {
              final message = timerNotification.message!;
              final titleMatch = RegExp(r'Next item: (.+?) \(').firstMatch(message);
              nextItemTitle = titleMatch?.group(1);
              if (message.toLowerCase().contains("auction sequence completed") || message.toLowerCase().contains("auction ended")) {
                // If message indicates sequence completion, reflect this
                // but actual status change to AUCTION_SEQUENCE_COMPLETED might come from its own event
              }
            }
            _startDelayTimer();
            stateChanged = true;
            break;

          case 'AUCTION_DELAY_COUNTDOWN':
            if (isInDelayPhase) {
              delaySecondsRemaining = timerNotification.remainingSeconds;
              // Update next item title if available in message
              if (timerNotification.message != null) {
                final message = timerNotification.message!;
                final titleMatch = RegExp(r'Next item: (.+?) \(').firstMatch(message);
                if (titleMatch != null) {
                  nextItemTitle = titleMatch.group(1);
                }
              }
              stateChanged = true;
            }
            break;

          case 'AUCTION_DELAY_COMPLETED':
            print('⏰ AUCTION_DELAY_COMPLETED received. Current auctionStatus: $auctionStatus');
            bool wasInDelayPhase = isInDelayPhase;
            isInDelayPhase = false;
            delaySecondsRemaining = 0;
            nextItemTitle = null;
            _stopDelayTimer();

            if (auctionStatus == "AUCTION_SEQUENCE_COMPLETED") {
              print('🏁 Auction sequence was completed. Delay finished. Setting flag to navigate.');
              _shouldNavigateAfterSequenceCompletion = true;
              // NotifyListeners will be called because stateChanged is true
            } else {
              // When delay ends, fetch the next active post in the auction
              print('⏰ AUCTION_DELAY_COMPLETED: Fetching next active post...');
              _fetchAndTransitionToNextPost();
            }
            stateChanged = true;
            break;

          case 'AUCTION_SEQUENCE_COMPLETED':
            print('🏁 AUCTION_SEQUENCE_COMPLETED event received.');
            auctionStatus = "AUCTION_SEQUENCE_COMPLETED";
            isTimerActive = false;
            isCurrentPostActive = false; // No post is active now
            isInDelayPhase = false; // Ensure delay phase is also marked as ended
            timeLeft = Duration.zero;
            _stopDelayTimer(); // Stop any active delay timer
            // A delay might start *after* this to show a final message.
            // Navigation flag will be set on AUCTION_DELAY_COMPLETED if this status holds.
            stateChanged = true;
            break;

          default:
            print('🤷 Unknown timer event: ${timerNotification.event}');
            break;
        }

        if (stateChanged && !_isDisposed) {
          notifyListeners();
        }
      } else {
        print('Timer event for another post (${timerNotification.postId}), ignoring for current post ${selectedPost.id}.');
      }
    } catch (e) {
      print('❌ Error processing timer update: $e. Raw body: ${frame.body}');
    }
  }

  // Update the _transitionToNextPost method in AuctionProvider class
  Future<void> _transitionToNextPost(int nextPostId) async {
    if (_isDisposed) return;

    try {
      print('🔄 Transitioning to next post: $nextPostId');
      isTransitioning = true;
      notifyListeners();

      ApiService apiService = ApiService();
      final nextPostData = await apiService.getPostById(nextPostId);

      if (_isDisposed) return;

      if (nextPostData == null) {
        print('❌ Failed to fetch next post data for ID: $nextPostId');
        isTransitioning = false;
        await _checkCurrentActivePost(); // Try to recover or get current state
        notifyListeners();
        return;
      }

      print('✅ Successfully fetched next post: ${nextPostData.title}');
      selectedPost = nextPostData;

      // Reset state for the new post
      bids = List.from(nextPostData.bids ?? []);
      if (bids.isNotEmpty) {
        bids.sort((a, b) => b.time.compareTo(a.time));
        lastBidTime = bids.first.time;
      } else {
        lastBidTime = null;
      }
      hasRecentBidActivity = false;

      // Reset auction provider's view of the post's state
      isCurrentPostActive = true; // Set this to true for the newly loaded post
      isTimerActive = true; // Assume the post is active and timer is running
      auctionStatus = "ACTIVE"; // Set status to ACTIVE instead of WAITING
      timeLeft = Duration(seconds: 30); // Start with full time
      remainingSeconds = 30;
      lastServerUpdate = DateTime.now();
      isInDelayPhase = false;

      // Update status in the selectedPost too
      selectedPost = selectedPost.copyWith(status: 'IN_PROGRESS');

      _timer?.cancel();
      _delayTimer?.cancel();
      _activityResetTimer?.cancel();

      _startLocalTimer();
      _setupSubscriptions();

      // After transition is complete, check with server for current state
      isTransitioning = false;
      print('🔄 Successfully transitioned to post: ${selectedPost.title}, ID: ${selectedPost.id}');
      notifyListeners();

      // Check with server for current state, but don't wait for it to update UI
      Timer(Duration(milliseconds: 500), () {
        if (!_isDisposed) {
          _checkCurrentActivePost();
        }
      });

    } catch (e) {
      print('❌ Error transitioning to next post: $e');
      if (!_isDisposed) {
        isTransitioning = false;
        await _checkCurrentActivePost();
        notifyListeners();
      }
    }
  }
  Future<void> _fetchAndTransitionToNextPost() async {
    if (_isDisposed || isTransitioning) return;

    try {
      print('🔍 Attempting to fetch and transition to next post in auction $auctionId');
      isTransitioning = true;
      isInDelayPhase = false;
      notifyListeners();

      // Get current active post for this auction
      final result = await ApiService.getCurrentActivePost(auctionId);
      if (_isDisposed) return;

      if (result != null && result['activePost'] != null) {
        final activePostId = result['activePost']['id'];

        // Only transition if it's a different post
        if (activePostId != selectedPost.id) {
          print('🔄 Found next active post ID: $activePostId. Transitioning...');
          await _transitionToNextPost(activePostId);
        } else {
          print('🔄 Current post is still active, refreshing state');
          _handleActivePostResponse(result);

          // If we get a result with the same post ID but it's not active,
          // it might mean the backend hasn't updated yet
          if (!isCurrentPostActive) {
            print('⚠️ Server says post is not active, but we expect it to be. Setting active locally.');
            isCurrentPostActive = true;
            auctionStatus = "ACTIVE";
            isTimerActive = true;
            timeLeft = Duration(seconds: 30);
            remainingSeconds = 30;
            lastServerUpdate = DateTime.now();
            notifyListeners();
          }
        }
      } else {
        // If no active post is returned, but we're in a transition state,
        // assume the new post should be active
        print('⚠️ No active post found from server. Setting current post as active.');
        auctionStatus = "ACTIVE";
        isCurrentPostActive = true;
        isTimerActive = true;
        timeLeft = Duration(seconds: 30);
        remainingSeconds = 30;
        lastServerUpdate = DateTime.now();
      }

      isTransitioning = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching next post: $e');
      if (!_isDisposed) {
        isTransitioning = false;

        // Even on error, assume the current post should be active
        auctionStatus = "ACTIVE";
        isCurrentPostActive = true;
        isTimerActive = true;
        notifyListeners();
      }
    }
  }
  void _updateTimer(int seconds) {
    remainingSeconds = seconds;
    timeLeft = Duration(seconds: seconds);
    lastServerUpdate = DateTime.now();
  }

// Update the delay timer mechanism to ensure transition happens when it reaches zero
  void _startDelayTimer() {
    _stopDelayTimer();
    _delayTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (isInDelayPhase && delaySecondsRemaining > 0) {
        delaySecondsRemaining--;
        notifyListeners();

        // When countdown reaches zero, transition to the next post automatically
        if (delaySecondsRemaining == 0) {
          print('⏱️ Delay countdown reached zero - automatically transitioning to next post');
          _stopDelayTimer();
          _fetchAndTransitionToNextPost();
        }
      }
    });
  }

  void _stopDelayTimer() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  void _onAuctionUpdate(StompFrame frame) {
    if (frame.body == null || _isDisposed) return;

    try {
      final data = json.decode(frame.body!);
      print('📡 Processing general auction update: $data');

      // Check if this is a bid update structure from the general auction topic
      if (data.containsKey('postId') && data.containsKey('newPrice') && data.containsKey('userIdentifier')) {
        final postId = data['postId'];
        final newPrice = (data['newPrice'] ?? 0.0).toDouble();
        final userName = data['userIdentifier'] ?? 'Unknown User';
        // final String timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();

        if (postId == selectedPost.id && newPrice > 0) {
          print('💰 Received bid update via general auction topic for current post ${selectedPost.id}: $newPrice by $userName');
          _updatePostWithNewBid(newPrice, userName);
        } else if (postId != selectedPost.id) {
          print('Bid update for a different post ($postId) received on general auction topic. Ignoring for current post ${selectedPost.id}.');
        }
      }
      // Potentially handle other types of general auction messages here
      // For example, messages about auction start/end if not covered by timer events
      else if (data.containsKey('event')) {
        // Could be a redundant timer event or other auction-level notification
        print('General auction event: ${data['event']}, Message: ${data['message']}');
        // You could map this to _onTimerUpdate logic if structures are similar
        // e.g., if (data['event'] == 'AUCTION_ENDED_EVENT') { ... }
      }
      else {
        print('📡 Unhandled general auction update structure: $data');
      }
    } catch (e) {
      print('❌ Error processing general auction update: $e. Raw body: ${frame.body}');
    }
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (isTimerActive && isCurrentPostActive && lastServerUpdate != null) {
        final elapsed = DateTime.now().difference(lastServerUpdate!).inSeconds;
        final left = remainingSeconds - elapsed;

        if (left <= 0) {
          timeLeft = Duration.zero;
          // isTimerActive = false; // Server should confirm timer expiry
          // Potentially call _checkCurrentActivePost or wait for TIMER_EXPIRED
        } else {
          timeLeft = Duration(seconds: left);
        }
        notifyListeners();
      } else if (!isTimerActive && timeLeft != Duration.zero) {
        // If timer is not active but timeLeft is non-zero, reset it.
        // timeLeft = Duration.zero;
        // notifyListeners();
      }
    });
  }

  void sendBid(double bidAmount) {
    print('💰 Attempting to send bid: $bidAmount for post ${selectedPost.id}');

    if (!_canUserBid()) {
      print('❌ Cannot bid: Status=$auctionStatus, CurrentPostActive=$isCurrentPostActive, TimerActive=$isTimerActive, InDelayPhase=$isInDelayPhase, WSConnected=$isWebSocketConnected');
      // Optionally show a message to the user via a snackbar or similar
      return;
    }

    // Validate bid amount against current price and bid step
    final minRequiredBid = getMinimumBid();
    if (bidAmount < minRequiredBid && !(selectedPost.finalPrice == 0.0 && bidAmount == selectedPost.startPrice)) { // Allow bidding start price if no bids yet
      print('❌ Bid amount $bidAmount is less than minimum required $minRequiredBid');
      // Optionally show error to user
      return;
    }


    if (_stompClient != null && isWebSocketConnected) {
      _sendBidViaWebSocket(bidAmount);
    } else {
      print('WebSocket not connected. Attempting HTTP bid as fallback.');
      _sendBidViaHttp(bidAmount);
    }
  }

  void _sendBidViaWebSocket(double bidAmount) {
    try {
      final bidData = {
        'postId': selectedPost.id,
        'amount': bidAmount, // This should be the total new price
        'timestamp': DateTime.now().toIso8601String(),
        // 'userId': 'current_user_id', // Send user identifier if backend expects it
      };

      print('📤 Sending WebSocket bid: ${json.encode(bidData)} to /app/auction/${selectedPost.id}/bid');

      _stompClient!.send(
        destination: '/app/auction/${selectedPost.id}/bid', // Ensure this matches your backend STOMP mapping
        body: json.encode(bidData),
      );
      print('Bid sent via WebSocket.');
    } catch (e) {
      print('❌ WebSocket bid error: $e. Falling back to HTTP.');
      _sendBidViaHttp(bidAmount);
    }
  }

  void _sendBidViaHttp(double bidAmount) async {
    try {
      print('📤 Sending HTTP bid: $bidAmount for post ${selectedPost.id}');
      final success = await ApiService.placeBid(selectedPost.id, bidAmount);
      if (success) {
        print('✅ HTTP bid placed successfully. Waiting for WebSocket confirmation or polling.');
        // After HTTP bid, you might want to fetch post details to update UI immediately
        // or rely on WebSocket to broadcast the change.
        // For now, we assume WebSocket will update.
      } else {
        print('❌ Failed to place bid via HTTP. Response indicated failure.');
        // Optionally show error to user
      }
    } catch (e) {
      print('❌ HTTP bid submission error: $e');
      // Optionally show error to user
    }
  }

  bool _isDisposed = false;

  bool _canUserBid() {
    // User can bid if the auction for the *current post* is active and not in a delay phase.
    return auctionStatus == "ACTIVE" &&
        isCurrentPostActive &&
        isTimerActive &&
        !isInDelayPhase &&
        !_isDisposed;
  }

  @override
  void dispose() {
    print('🧹 Disposing AuctionProvider for auction $auctionId, post ${selectedPost.id}');
    _isDisposed = true;

    _timer?.cancel();
    _delayTimer?.cancel();
    _activityResetTimer?.cancel();
    _cancelReconnectionTimer();

    if (_stompClient != null && _stompClient!.connected) {
      try {
        // Unsubscribe from topics if subscription IDs were stored.
        // Example: if (_bidSubscriptionId != null) _stompClient.unsubscribe(_bidSubscriptionId);
        _stompClient!.deactivate();
        print('STOMP client deactivated.');
      } catch (e) {
        print('Error deactivating STOMP client: $e');
      }
    }
    _stompClient = null;

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

// Extension to add copyWith method to Post
extension PostCopyWith on Post {
  Post copyWith({
    int? id,
    String? title,
    String? description,
    double? startPrice,
    double? currentBid,
    int? numberOfOnAuction,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    List<String>? media,
    String? category,
    int? viewCount,
    List<Bid>? bids,
    String? isLive,
    int? numberOfBidders,
    double? bidStep,
    bool? isFav,
    String? status,
    double? finalPrice,
    int? numberOfPostInAuction,
    bool? isAccepted,
    DateTime? createdDate,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startPrice: startPrice ?? this.startPrice,
      currentBid: currentBid ?? this.currentBid,
      numberOfOnAuction: numberOfOnAuction ?? this.numberOfOnAuction,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      media: media ?? this.media,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      bids: bids ?? this.bids,
      isLive: isLive ?? this.isLive,
      numberOfBidders: numberOfBidders ?? this.numberOfBidders,
      bidStep: bidStep ?? this.bidStep,
      isFav: isFav ?? this.isFav,
      status: status ?? this.status,
      finalPrice: finalPrice ?? this.finalPrice,
      numberOfPostInAuction: numberOfPostInAuction ?? this.numberOfPostInAuction,
      isAccepted: isAccepted ?? this.isAccepted,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  void debugPrint() {
    print('Post Debug Info:');
    print('  ID: $id');
    print('  Title: $title');
    print('  Status: $status');
    print('  Start Price: $startPrice');
    print('  Current Bid: $currentBid');
    print('  Final Price: $finalPrice');
    print('  Calculated Current Price (for debug): ${_getCurrentPrice()}');
    print('  Bid Step: $bidStep');
    print('  Bids Count (from Post object): ${bids?.length ?? 0}');
  }

  double _getCurrentPrice() { // Internal helper for debug print
    if (finalPrice != null && finalPrice! > 0) {
      return finalPrice!;
    } else if (currentBid != null && currentBid! > 0) {
      return currentBid!;
    } else {
      return startPrice;
    }
  }
}