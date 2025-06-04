import 'dart:async';
import 'dart:convert';

import 'package:application/API_Service/api.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/bid_button_sheet.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

// Import your AppColors class
import 'package:application/constants/app_colors.dart';
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

class AuctionDetailPage extends StatefulWidget {
  final Post post;
  final int? auctionId;

  const AuctionDetailPage({
    super.key,
    required this.post,
    required this.auctionId,
  });

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  late Post selectedPost;
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  // Timer and auction status
  bool _isTimerActive = false;
  bool _isCurrentPostActive = false; // Is THIS post currently active in the auction
  int _serverRemainingSeconds = 0;
  DateTime? _lastTimerUpdate;
  String _auctionStatus = "WAITING"; // WAITING, ACTIVE, COMPLETED, AUCTION_COMPLETED

  // WebSocket related
  StompClient? _stompClient;
  bool _isWebSocketConnected = false;
  late String _webSocketUrl;

  List<Bid> _bids = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    selectedPost = widget.post;
    _bids = widget.post.bids ?? [];

    print("=== INITIALIZATION ===");
    print("Initial bids count: ${widget.post.bids?.length ?? 0}");
    print("Initial final price: ${selectedPost.finalPrice}");
    print("Initial current bid: ${selectedPost.currentBid}");
    print("Initial start price: ${selectedPost.startPrice}");

    // WebSocket URL
    _webSocketUrl = AppConfig.webSocketUrl;

    _initializeWebSocket();
    _startConnectionMonitoring();
    _startDebugMonitoring();
    _checkCurrentActivePost();
    _startLocalTimer();

    // Print initial state
    _debugCurrentState();
  }


  void _checkCurrentActivePost() async {
    // Check if this post is currently the active one in the auction sequence
    try {
      print('🔍 Checking current active post for auction ${widget.auctionId}');

      if (widget.auctionId == null) {
        print('⚠️ No auction ID provided');
        return;
      }

      final result = await ApiService.getCurrentActivePost(widget.auctionId!);

      if (result != null && mounted) {
        print('✅ Got active post result: $result');

        final activePost = result['activePost'];
        final remainingSeconds = result['remainingSeconds'] ?? 0;
        final isTimerActive = result['isTimerActive'] ?? false;

        setState(() {
          _isCurrentPostActive = activePost != null && activePost['id'] == selectedPost.id;
          _isTimerActive = _isCurrentPostActive && isTimerActive;
          _serverRemainingSeconds = remainingSeconds;

          // Determine auction status based on post status and timer state
          if (selectedPost.status == 'COMPLETED') {
            _auctionStatus = "COMPLETED";
          } else if (_isCurrentPostActive && _isTimerActive) {
            _auctionStatus = "ACTIVE";
            _timeLeft = Duration(seconds: _serverRemainingSeconds);
            _lastTimerUpdate = DateTime.now();
          } else if (selectedPost.status == 'IN_PROGRESS') {
            _auctionStatus = "ACTIVE";
            _isCurrentPostActive = true;
          } else {
            _auctionStatus = "WAITING";
          }
        });

        print('📊 Post ${selectedPost.id} analysis:');
        print('   - Status: $_auctionStatus');
        print('   - Is current active: $_isCurrentPostActive');
        print('   - Timer active: $_isTimerActive');
        print('   - Remaining: $_serverRemainingSeconds seconds');
        print('   - Post status: ${selectedPost.status}');

      } else {
        print('⚠️ No result from getCurrentActivePost, using fallback logic');
        // Fallback: determine status from post data
        setState(() {
          if (selectedPost.status == 'COMPLETED') {
            _auctionStatus = "COMPLETED";
            _isCurrentPostActive = false;
            _isTimerActive = false;
          } else if (selectedPost.status == 'IN_PROGRESS') {
            _auctionStatus = "ACTIVE";
            _isCurrentPostActive = true;
            _isTimerActive = true;
            _timeLeft = Duration(seconds: 30); // Default to 30 seconds
            _lastTimerUpdate = DateTime.now();
          } else {
            _auctionStatus = "WAITING";
            _isCurrentPostActive = false;
            _isTimerActive = false;
          }
        });
      }
    } catch (e) {
      print('❌ Error checking current active post: $e');

      // Fallback: Use post status to determine state
      setState(() {
        if (selectedPost.status == 'COMPLETED') {
          _auctionStatus = "COMPLETED";
          _isCurrentPostActive = false;
          _isTimerActive = false;
        } else if (selectedPost.status == 'IN_PROGRESS') {
          _auctionStatus = "ACTIVE";
          _isCurrentPostActive = true;
          _isTimerActive = true;
          _timeLeft = Duration(seconds: 30);
          _lastTimerUpdate = DateTime.now();
        } else {
          _auctionStatus = "WAITING";
          _isCurrentPostActive = false;
          _isTimerActive = false;
        }
      });

      print('🔄 Using fallback status: $_auctionStatus');
    }
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isTimerActive && _isCurrentPostActive && _lastTimerUpdate != null) {
        final elapsed = DateTime.now().difference(_lastTimerUpdate!);
        final remaining = _serverRemainingSeconds - elapsed.inSeconds;

        if (remaining <= 0) {
          setState(() {
            _timeLeft = Duration.zero;
            _isTimerActive = false;
            _auctionStatus = "COMPLETED";
          });
          timer.cancel();
        } else {
          setState(() {
            _timeLeft = Duration(seconds: remaining);
          });
        }
      }
    });
  }

  void _initializeWebSocket() async {
    try {
      // Get the authentication token
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      print('🔐 Initializing WebSocket with token: ${token != null ? "Present" : "Missing"}');

      _stompClient = StompClient(
        config: StompConfig(
          url: _webSocketUrl,
          onConnect: _onWebSocketConnected,
          onWebSocketError: (dynamic error) {
            print('❌ WebSocket Error: $error');
            setState(() => _isWebSocketConnected = false);

            // Try to reconnect after a delay
            Future.delayed(Duration(seconds: 5), () {
              if (mounted && !_isWebSocketConnected) {
                print('🔄 Attempting to reconnect WebSocket...');
                _initializeWebSocket();
              }
            });
          },
          onStompError: (StompFrame frame) {
            print('❌ Stomp Error: ${frame.body}');
            setState(() => _isWebSocketConnected = false);
          },
          onDisconnect: (StompFrame frame) {
            print('🔌 WebSocket Disconnected: ${frame.body}');
            setState(() => _isWebSocketConnected = false);
          },
          // Add authentication headers
          webSocketConnectHeaders: token != null ? {
            'Authorization': 'Bearer $token',
          } : {},
          stompConnectHeaders: token != null ? {
            'Authorization': 'Bearer $token',
          } : {},
          heartbeatIncoming: Duration(seconds: 20),
          heartbeatOutgoing: Duration(seconds: 20),
          // Add reconnection configuration
          connectionTimeout: Duration(seconds: 10),
        ),
      );

      print('🚀 Activating WebSocket connection...');
      _stompClient!.activate();
    } catch (e) {
      print('❌ Failed to initialize WebSocket: $e');
      setState(() => _isWebSocketConnected = false);
    }
  }

  void _onWebSocketConnected(StompFrame frame) {
    print('✅ WebSocket Connected Successfully');
    print('📡 Connection frame: ${frame.body}');
    setState(() => _isWebSocketConnected = true);

    try {
      // Subscribe to bid updates for this specific post
      print('📡 Subscribing to bid updates for post ${selectedPost.id}');
      _stompClient!.subscribe(
        destination: '/topic/auction/${selectedPost.id}/bids',
        callback: _onBidUpdateEnhanced,
      );

      // Subscribe to timer updates for this specific post
      print('📡 Subscribing to timer updates for post ${selectedPost.id}');
      _stompClient!.subscribe(
        destination: '/topic/auction/${selectedPost.id}/timer',
        callback: _onTimerUpdate,
      );

      // Subscribe to auction-wide updates
      if (widget.auctionId != null) {
        print('📡 Subscribing to auction updates for auction ${widget.auctionId}');
        _stompClient!.subscribe(
          destination: '/topic/auction/${widget.auctionId}',
          callback: _onAuctionUpdate,
        );
      }

      // Subscribe to tracker updates
      print('📡 Subscribing to tracker updates for post ${selectedPost.id}');
      _stompClient!.subscribe(
        destination: '/topic/auction/${selectedPost.id}/trackers',
        callback: _onTrackerUpdate,
      );

      print('✅ All WebSocket subscriptions completed');

      // Send a connect message to the server (optional)
      _stompClient!.send(
        destination: '/app/auction/connect',
        body: json.encode({
          'postId': selectedPost.id,
          'auctionId': widget.auctionId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

    } catch (e) {
      print('❌ Error setting up WebSocket subscriptions: $e');
    }
  }
  void _debugCurrentState() {
    final currentPrice = selectedPost.finalPrice ?? selectedPost.startPrice;

    print('🔍 === ENHANCED STATE DEBUG ===');
    print('Post ID: ${selectedPost.id}');
    print('Post Status: ${selectedPost.status}');
    print('Post Final Price: ${selectedPost.finalPrice}');
    print('Post Current Bid: ${selectedPost.currentBid}');
    print('Post Start Price: ${selectedPost.startPrice}');
    print('Computed Current Price: $currentPrice');
    print('Auction Status: $_auctionStatus');
    print('Is Current Post Active: $_isCurrentPostActive');
    print('Is Timer Active: $_isTimerActive');
    print('Time Left: ${_timeLeft.inSeconds} seconds');
    print('WebSocket Connected: $_isWebSocketConnected');
    print('Bids Count: ${_bids.length}');
    print('Server Remaining Seconds: $_serverRemainingSeconds');
    print('Last Timer Update: $_lastTimerUpdate');
    print('Can Bid: ${_canUserBid()}');
    print('=== END ENHANCED DEBUG ===');
  }
  bool _canUserBid() {
    return _auctionStatus == "ACTIVE" &&
        _isCurrentPostActive &&
        _isTimerActive &&
        _isWebSocketConnected;
  }

// Call this method periodically to monitor state
  void _startDebugMonitoring() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _debugCurrentState();
    });
  }

// Test method to simulate a bid (for testing WebSocket)
  void _testBid() {
    if (_stompClient != null && _isWebSocketConnected) {
      final testBidData = {
        'postId': selectedPost.id,
        'amount': (selectedPost.finalPrice ?? selectedPost.startPrice) + selectedPost.bidStep,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('🧪 Testing bid with data: $testBidData');

      _stompClient!.send(
        destination: '/app/auction/${selectedPost.id}/bid',
        body: json.encode(testBidData),
      );
    }
  }

// Add a floating action button for testing (remove in production)
  Widget _buildDebugFAB() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Debug Actions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _debugCurrentState,
                  child: Text('Print Debug Info'),
                ),
                ElevatedButton(
                  onPressed: _testBid,
                  child: Text('Test Bid'),
                ),
                ElevatedButton(
                  onPressed: _checkCurrentActivePost,
                  child: Text('Refresh Post Status'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _auctionStatus = "ACTIVE";
                      _isCurrentPostActive = true;
                      _isTimerActive = true;
                      _timeLeft = Duration(seconds: 30);
                      _lastTimerUpdate = DateTime.now();
                    });
                  },
                  child: Text('Force Active State'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Icon(Icons.bug_report),
    );
  }
  void _updatePostState({
    double? newFinalPrice,
    String? newStatus,
    bool? isActive,
    bool? timerActive,
    Duration? timeLeft,
  }) {
    setState(() {
      if (newFinalPrice != null) {
        selectedPost.finalPrice = newFinalPrice;
        selectedPost.currentBid = newFinalPrice; // Ensure backward compatibility
        print('💰 Updated post price to: $newFinalPrice');
      }

      if (newStatus != null) {
        selectedPost.status = newStatus;
        print('📊 Updated post status to: $newStatus');
      }

      if (isActive != null) {
        _isCurrentPostActive = isActive;
        print('🎯 Updated post active state to: $isActive');
      }

      if (timerActive != null) {
        _isTimerActive = timerActive;
        print('⏰ Updated timer active state to: $timerActive');
      }

      if (timeLeft != null) {
        _timeLeft = timeLeft;
        _lastTimerUpdate = DateTime.now();
        print('⏱️ Updated time left to: ${timeLeft.inSeconds} seconds');
      }
    });
  }

// Enhanced bid update handler with state validation
  void _onBidUpdateEnhanced(StompFrame frame) {
    try {
      if (frame.body == null) return;

      print('📨 Received bid update: ${frame.body}');
      final data = json.decode(frame.body!);
      final bidUpdate = BidUpdateDTO.fromJson(data);

      print('💰 Processing bid update:');
      print('   - Post ID: ${bidUpdate.postId} (Expected: ${selectedPost.id})');
      print('   - New Final Price: ${bidUpdate.finalPrice}');
      print('   - Current Final Price: ${selectedPost.finalPrice}');
      print('   - User: ${bidUpdate.userName}');

      if (bidUpdate.postId == selectedPost.id) {
        // Store old price for comparison
        final oldPrice = selectedPost.finalPrice ?? selectedPost.currentBid ?? selectedPost.startPrice;

        // Update state using the enhanced method
        _updatePostState(newFinalPrice: bidUpdate.finalPrice);

        // Create and add new bid
        final newBid = Bid(
          userId: DateTime.now().millisecondsSinceEpoch,
          amount: bidUpdate.finalPrice,
          userName: bidUpdate.userName,
          time: DateTime.now(),
        );

        setState(() {
          _bids.insert(0, newBid);
        });

        print('✅ Bid update processed:');
        print('   - Old Price: ${oldPrice.toStringAsFixed(2)}');
        print('   - New Price: ${bidUpdate.finalPrice.toStringAsFixed(2)}');
        print('   - Total Bids: ${_bids.length}');

        // Force UI rebuild
        Future.microtask(() {
          if (mounted) {
            setState(() {});
          }
        });

        // Show notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '💰 New bid: ${bidUpdate.finalPrice.toStringAsFixed(2)} NIS by ${bidUpdate.userName}',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('ℹ️ Bid update for different post (${bidUpdate.postId}), ignoring');
      }
    } catch (e) {
      print('❌ Error processing bid update: $e');
    }
  }

  void _onTimerUpdate(StompFrame frame) {
    try {
      if (frame.body == null) return;

      print('📨 Received timer update: ${frame.body}');
      final data = json.decode(frame.body!);
      final timerNotification = TimerNotification.fromJson(data);

      print('🔍 Timer event: ${timerNotification.event} for post ${timerNotification.postId}');
      print('🔍 Current post ID: ${selectedPost.id}');
      print('🔍 Current status: $_auctionStatus');

      // Handle events for this specific post
      if (timerNotification.postId == selectedPost.id) {
        setState(() {
          switch (timerNotification.event) {
            case 'POST_STARTED':
              print('🎯 POST_STARTED event for current post');
              _isCurrentPostActive = true;
              _isTimerActive = true;
              _auctionStatus = "ACTIVE";
              _serverRemainingSeconds = timerNotification.remainingSeconds;
              _timeLeft = Duration(seconds: _serverRemainingSeconds);
              _lastTimerUpdate = DateTime.now();
              selectedPost.status = 'IN_PROGRESS';

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎯 Now auctioning: ${selectedPost.title}'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              break;

            case 'TIMER_STARTED':
              print('⏰ TIMER_STARTED event for current post');
              _isCurrentPostActive = true;
              _isTimerActive = true;
              _auctionStatus = "ACTIVE";
              _serverRemainingSeconds = timerNotification.remainingSeconds;
              _timeLeft = Duration(seconds: _serverRemainingSeconds);
              _lastTimerUpdate = DateTime.now();
              selectedPost.status = 'IN_PROGRESS';
              break;

            case 'TIMER_RESTARTED':
              print('🔄 TIMER_RESTARTED event for current post');
              if (_isCurrentPostActive) {
                _isTimerActive = true;
                _serverRemainingSeconds = timerNotification.remainingSeconds;
                _timeLeft = Duration(seconds: _serverRemainingSeconds);
                _lastTimerUpdate = DateTime.now();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⏰ Timer restarted to 30 seconds due to new bid!'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
              break;

            case 'TIMER_STOPPED':
              print('⏹️ TIMER_STOPPED event for current post');
              if (_isCurrentPostActive) {
                _isTimerActive = false;
                _timeLeft = Duration.zero;
              }
              break;

            case 'TIMER_EXPIRED':
              print('🔥 TIMER_EXPIRED event for current post');
              _isTimerActive = false;
              _isCurrentPostActive = false;
              _timeLeft = Duration.zero;
              _auctionStatus = "COMPLETED";
              selectedPost.status = 'COMPLETED';

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🏁 Auction ended for this item! Moving to next item...'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
              break;
          }
        });
      }

      // Handle auction-wide events
      if (timerNotification.event == 'AUCTION_SEQUENCE_COMPLETED') {
        print('🎊 AUCTION_SEQUENCE_COMPLETED event');
        setState(() {
          _auctionStatus = "AUCTION_COMPLETED";
          _isTimerActive = false;
          _isCurrentPostActive = false;
          _timeLeft = Duration.zero;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎊 Entire auction completed! ${timerNotification.message ?? ""}'),
              backgroundColor: Colors.purple,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }

      // Show message if provided
      if (timerNotification.message != null && mounted) {
        print('💬 Timer message: ${timerNotification.message}');
      }

      print('🔍 Updated status: $_auctionStatus, timer active: $_isTimerActive, post active: $_isCurrentPostActive');

    } catch (e) {
      print('❌ Error processing timer update: $e');
    }
  }

  void _onAuctionUpdate(StompFrame frame) {
    print('Received auction update: ${frame.body}');
    // Handle auction-wide updates here
  }

  void _onTrackerUpdate(StompFrame frame) {
    print('Received tracker update: ${frame.body}');
    // Handle bid tracker updates here
  }

  void _sendBid(double amount) {
    print('💰 Attempting to send bid: $amount for post ${selectedPost.id}');

    if (!_isCurrentPostActive) {
      print('❌ Post ${selectedPost.id} is not currently active for bidding');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This item is not currently active for bidding'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_stompClient != null && _isWebSocketConnected) {
      try {
        final bidData = {
          'postId': selectedPost.id,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        };

        print('📤 Sending bid via WebSocket: $bidData');

        _stompClient!.send(
          destination: '/app/auction/${selectedPost.id}/bid',
          body: json.encode(bidData),
        );

        print('✅ Bid sent via WebSocket successfully');

        // Show immediate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid of ${amount.toStringAsFixed(2)} NIS sent!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

      } catch (e) {
        print('❌ Error sending bid via WebSocket: $e');
        _sendBidHttp(amount);
      }
    } else {
      print('❌ WebSocket not connected (connected: $_isWebSocketConnected), using HTTP API fallback');
      _sendBidHttp(amount);
    }
  }
  void _startConnectionMonitoring() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_isWebSocketConnected && _stompClient != null) {
        print('🔍 WebSocket disconnected, attempting to reconnect...');
        _initializeWebSocket();
      }
    });
  }
  void _sendBidHttp(double amount) async {
    try {
      bool success = await ApiService.placeBid(selectedPost.id, amount);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid placed successfully via HTTP!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place bid'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error placing bid via HTTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing bid: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _pageController.dispose();

    // Clean up WebSocket connection
    if (_stompClient != null) {
      _stompClient!.deactivate();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _error ?? 'خطأ غير معروف',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                selectedPost.title,
                style: TextStyle(color: AppColors.textPrimary(context)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusIndicators(),
          ],
        ),
        backgroundColor: AppColors.cardBackground(context),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildAuctionStatusBar(),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageCarousel(),
                          const SizedBox(height: 16),
                          _buildCategoryBadge(),
                          const SizedBox(height: 12),
                          _buildTitle(),
                          const SizedBox(height: 12),
                          _buildStats(),
                          const SizedBox(height: 8),
                          _buildBidInfo(),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryLightDark(context),
                        unselectedLabelColor: AppColors.textSecondary(context),
                        indicatorColor: AppColors.primaryLightDark(context),
                        dividerColor: AppColors.divider(context),
                        tabs: [
                          Tab(text: "bids".tr()),
                          Tab(text: "details".tr()),
                          Tab(text: "rules".tr()),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildBidsTab(),
                  _buildDetailsTab(),
                  _buildRulesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatusIndicators() {
    return Row(
      children: [
        // WebSocket connection indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _isWebSocketConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        // Auction status indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_auctionStatus) {
      case "ACTIVE":
        return Colors.green;
      case "WAITING":
        return Colors.orange;
      case "COMPLETED":
        return Colors.red;
      case "AUCTION_COMPLETED":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAuctionStatusBar() {
    final totalDuration = const Duration(seconds: 30);
    final progress = _isTimerActive && _timeLeft.inSeconds > 0
        ? 1 - (_timeLeft.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : (_auctionStatus == "COMPLETED" ? 1.0 : 0.0);

    final Color barColor = _getStatusColor();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 768;
    final isLargeScreen = screenWidth >= 768;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(_timeLeft.inHours % 24);
    final m = twoDigits(_timeLeft.inMinutes % 60);
    final s = twoDigits(_timeLeft.inSeconds % 60);

    String statusText = _getStatusText();
    String timerText = _isTimerActive ? "$h:$m:$s" : statusText;

    return Container(
      color: AppColors.cardBackground(context),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with timer and status indicators
          Row(
            children: [
              // Timer text with responsive sizing
              Expanded(
                child: Text(
                  _isTimerActive
                      ? "time_left".tr(namedArgs: {'count': timerText})
                      : timerText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(screenWidth, isTimerActive: _isTimerActive),
                    color: barColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isSmallScreen ? 2 : 1,
                ),
              ),
              const SizedBox(width: 8),
              // Status indicators with responsive layout
              _buildResponsiveStatusIndicators(screenWidth),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          // Progress bar with responsive styling
          _buildResponsiveProgressBar(progress, barColor, screenWidth),
          // Additional status info for completed auctions
          if (_auctionStatus == "COMPLETED" || _auctionStatus == "AUCTION_COMPLETED")
            _buildCompletedStatusInfo(screenWidth),
        ],
      ),
    );
  }
  double _getResponsiveFontSize(double screenWidth, {bool isTimerActive = false}) {
    if (screenWidth < 360) {
      return isTimerActive ? 12 : 11;
    } else if (screenWidth < 768) {
      return isTimerActive ? 14 : 13;
    } else {
      return isTimerActive ? 16 : 15;
    }
  }

  Widget _buildResponsiveStatusIndicators(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    if (isSmallScreen) {
      // Compact layout for small screens
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                size: 14,
                color: _isWebSocketConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                _isWebSocketConnected ? 'Live' : 'Off',
                style: TextStyle(
                  fontSize: 10,
                  color: _isWebSocketConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 14,
                color: _getStatusColor(),
              ),
              const SizedBox(width: 2),
              Text(
                _getStatusLabel(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Normal layout for medium and large screens
      return Row(
        children: [
          Icon(
            _isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
            size: screenWidth < 768 ? 16 : 18,
            color: _isWebSocketConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            _isWebSocketConnected ? 'Live' : 'Offline',
            style: TextStyle(
              fontSize: screenWidth < 768 ? 12 : 14,
              color: _isWebSocketConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _getStatusIcon(),
            size: screenWidth < 768 ? 16 : 18,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(),
            style: TextStyle(
              fontSize: screenWidth < 768 ? 12 : 14,
              color: _getStatusColor(),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveProgressBar(double progress, Color barColor, double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      child: Stack(
        children: [
          // Background bar
          Container(
            height: isSmallScreen ? 8 : 10,
            width: double.infinity,
            color: AppColors.progressBackground(context),
          ),
          // Progress bar with animation
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isSmallScreen ? 8 : 10,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: _getProgressGradient(barColor),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              boxShadow: _isTimerActive ? [
                BoxShadow(
                  color: barColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ] : null,
            ),
          ),
          // Pulse effect for active timer
          if (_isTimerActive && _timeLeft.inSeconds <= 10)
            AnimatedOpacity(
              opacity: (_timeLeft.inSeconds % 2 == 0) ? 0.7 : 1.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                height: isSmallScreen ? 8 : 10,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
  LinearGradient _getProgressGradient(Color baseColor) {
    switch (_auctionStatus) {
      case "ACTIVE":
        return LinearGradient(
          colors: [baseColor, baseColor.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case "COMPLETED":
        return LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case "AUCTION_COMPLETED":
        return LinearGradient(
          colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return LinearGradient(
          colors: [baseColor, baseColor.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  Widget _buildCompletedStatusInfo(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 4 : 6),
      child: Row(
        children: [
          Icon(
            _auctionStatus == "AUCTION_COMPLETED" ? Icons.celebration : Icons.check_circle,
            size: isSmallScreen ? 14 : 16,
            color: _auctionStatus == "AUCTION_COMPLETED" ? Colors.purple : Colors.green,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _auctionStatus == "AUCTION_COMPLETED"
                  ? "All auction items completed!"
                  : "This item auction completed",
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: AppColors.textSecondary(context),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_bids.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8,
                vertical: isSmallScreen ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                "${_bids.length} bids",
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 11,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  IconData _getStatusIcon() {
    switch (_auctionStatus) {
      case "ACTIVE":
        return Icons.timer;
      case "WAITING":
        return Icons.hourglass_empty;
      case "COMPLETED":
        return Icons.check_circle;
      case "AUCTION_COMPLETED":
        return Icons.celebration;
      default:
        return Icons.timer_off;
    }
  }

  String _getStatusLabel() {
    switch (_auctionStatus) {
      case "ACTIVE":
        return "Active";
      case "WAITING":
        return "Waiting";
      case "COMPLETED":
        return "Completed";
      case "AUCTION_COMPLETED":
        return "Auction Done";
      default:
        return "Unknown";
    }
  }

  String _getStatusText() {
    switch (_auctionStatus) {
      case "ACTIVE":
        return "Currently active - place your bids!";
      case "WAITING":
        return "Waiting for your turn in the auction";
      case "COMPLETED":
        return "Auction completed for this item";
      case "AUCTION_COMPLETED":
        return "Entire auction sequence completed";
      default:
        return "Waiting for auction to start";
    }
  }

  Widget _buildImageCarousel() {
    final images = selectedPost.media.isNotEmpty ? selectedPost.media : ['assets/images/placeholder.png'];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = images[index];
              return GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceVariant(context),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (images.length > 1) _buildImageIndicators(images.length),
          _buildLiveBadge(),
        ],
      ),
    );
  }

  Widget _buildImageIndicators(int imageCount) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          imageCount,
              (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              _selectedImageIndex == index
                  ? AppColors.primaryLightDark(context)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _getStatusColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightBackground(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            selectedPost.category,
            style: TextStyle(
              color: AppColors.primaryLightDark(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      selectedPost.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Icon(Icons.gavel, size: 16, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Text(
          'bidders'.tr(
            namedArgs: {'count': (_bids.length).toString()},
          ),
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.remove_red_eye,
          size: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 4),
        Text(
          "views".tr(namedArgs: {'count': selectedPost.viewCount.toString()}),
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }

  Widget _buildBidInfo() {
    // Always get the most current price
    final currentPrice = selectedPost.finalPrice ?? selectedPost.currentBid ?? selectedPost.startPrice;
    final nextBidPrice = currentPrice + selectedPost.bidStep;

    print('🔍 Building bid info with currentPrice: $currentPrice');

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight(context),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  "highest_bid".tr(),
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "NIS ${currentPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryLightDark(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLightDark(context).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                  "place_bid",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "NIS ${nextBidPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final currentPrice = selectedPost.finalPrice ?? selectedPost.currentBid ?? selectedPost.startPrice;
    final canBid = _auctionStatus == "ACTIVE" &&
        _isCurrentPostActive &&
        _isTimerActive &&
        _isWebSocketConnected;

    print('🔍 Building bottom bar with currentPrice: $currentPrice, canBid: $canBid');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "current_bid".tr(),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "NIS ${currentPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: canBid ? () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BidBottomSheet(
                      post: selectedPost,
                      onBidPlaced: _sendBid,
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBid
                      ? AppColors.primaryLightDark(context)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _getBidButtonText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBidButtonText() {
    switch (_auctionStatus) {
      case "ACTIVE":
        return _isWebSocketConnected ? "place_bid".tr() : "connecting".tr();
      case "WAITING":
        return "waiting_for_turn".tr();
      case "COMPLETED":
        return "auction_ended".tr();
      case "AUCTION_COMPLETED":
        return "auction_finished".tr();
      default:
        return "waiting_for_auction".tr();
    }
  }

  // Rest of the methods (tabs, etc.) remain largely the same...
  // I'll include a few key ones:

  Widget _buildBidsTab() {
    final allBids = List<Bid>.from(_bids);
    allBids.sort((a, b) => b.time.compareTo(a.time));

    if (allBids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              "لا توجد مزايدات حتى الآن",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_auctionStatus == "ACTIVE")
              Text(
                "This item is currently active - be the first to bid!",
                style: TextStyle(fontSize: 12, color: Colors.green),
              )
            else if (_auctionStatus == "WAITING")
              Text(
                "Waiting for this item's turn in the auction...",
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allBids.length,
      itemBuilder: (context, index) {
        final bid = allBids[index];
        final isFirst = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(12),
            border:
            isFirst
                ? Border.all(
              color: AppColors.primaryLightDark(context),
              width: 2,
            )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bid.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        if (isFirst) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightDark(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "highest_bid".tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _getTimeAgo(bid.time),
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "NIS ${bid.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                  isFirst
                      ? AppColors.primaryLightDark(context)
                      : AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "ago_days".tr(namedArgs: {'count': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return "ago_hours".tr(
        namedArgs: {'count': difference.inHours.toString()},
      );
    } else if (difference.inMinutes > 0) {
      return "ago_minutes".tr(
        namedArgs: {'count': difference.inMinutes.toString()},
      );
    } else {
      return "ago_seconds".tr(
        namedArgs: {'count': difference.inSeconds.toString()},
      );
    }
  }

  // Additional methods for details and rules tabs would be similar to previous implementation
  // but I'll include the essential ones for space

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "post_info".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.category,
                title: "category".tr(),
                value: selectedPost.category,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.gavel,
                title: "bidders_count".tr(),
                value: "bidders".tr(
                  namedArgs: {
                    'count': _bids.length.toString(),
                  },
                ),
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.remove_red_eye,
                title: "views".tr(),
                value: "views".tr(
                  namedArgs: {'count': selectedPost.viewCount.toString()},
                ),
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.price_change,
                title: "starting_price".tr(),
                value: "NIS ${selectedPost.startPrice.toStringAsFixed(2)}",
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.add_circle_outline,
                title: "bid_step".tr(),
                value: "NIS ${selectedPost.bidStep.toStringAsFixed(2)}",
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.access_time,
                title: "auction_status".tr(),
                value: _getStatusLabel(),
              ),
              if (_isTimerActive) ...[
                Divider(color: AppColors.divider(context)),
                _buildInfoRow(
                  icon: Icons.timer,
                  title: "remaining_time".tr(),
                  value: "${_timeLeft.inSeconds} seconds",
                ),
              ],
              if (selectedPost.sellerId != null) ...[
                Divider(color: AppColors.divider(context)),
                _buildInfoRow(
                  icon: Icons.person,
                  title: "seller".tr(),
                  value: selectedPost.sellerName ?? "غير محدد",
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary(context)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "sequential_auction_rules".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                number: 1,
                title: "rule_sequential_order".tr(),
                description: "يتم عرض المنتجات في المزاد واحداً تلو الآخر حسب الترتيب المحدد مسبقاً.",
              ),
              _buildRuleItem(
                number: 2,
                title: "rule_timer_restart".tr(),
                description: "عند وضع مزايدة جديدة، يتم إعادة تشغيل المؤقت إلى 30 ثانية كاملة.",
              ),
              _buildRuleItem(
                number: 3,
                title: "rule_auto_progression".tr(),
                description: "عند انتهاء وقت المنتج الحالي، يتم الانتقال تلقائياً للمنتج التالي في القائمة.",
              ),
              _buildRuleItem(
                number: 4,
                title: "rule_min_bid".tr(),
                description: "الحد الأدنى للمزايدة هو ${selectedPost.bidStep.toStringAsFixed(2)} شيكل فوق آخر مزايدة.",
              ),
              _buildRuleItem(
                number: 5,
                title: "rule_commitment".tr(),
                description: "المزايد الفائز ملزم بإتمام عملية الشراء خلال 48 ساعة من انتهاء المزاد.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryLightDark(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(color: AppColors.cardBackground(context), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}