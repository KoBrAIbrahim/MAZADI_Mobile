import 'dart:async';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/bid_button_sheet.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:application/constants/app_colors.dart';

import '../../../models/AuctionProvider.dart';

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
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuctionProvider(
        selectedPost: widget.post,
        auctionId: widget.auctionId ?? 0,
      ),
      child: Consumer<AuctionProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground(context),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  context.go("/home_screen"); // عدّل هذا المسار حسب مسار صفحة المزاد عندك
                },
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.selectedPost.title,
                      style: TextStyle(color: AppColors.textPrimary(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusIndicators(provider),
                ],
              ),
              backgroundColor: AppColors.cardBackground(context),
              iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
              elevation: 0,
            ),
            body: Column(
              children: [
                _buildAuctionStatusBar(provider),
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
                                _buildImageCarousel(provider),
                                const SizedBox(height: 16),
                                _buildCategoryBadge(provider),
                                const SizedBox(height: 12),
                                _buildTitle(provider),
                                const SizedBox(height: 12),
                                _buildStats(provider),
                                const SizedBox(height: 8),
                                _buildBidInfo(provider),
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
                        _buildBidsTab(provider),
                        _buildDetailsTab(provider),
                        _buildRulesTab(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(provider),
          );
        },
      ),
    );
  }

  Widget _buildNextBidButtonWithTimer(AuctionProvider provider) {
    if (provider.isTransitioning) {
      // Show loading state during transition
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
      );
    }

    if (provider.isInDelayPhase) {
      // Show delay countdown on the button
      final progress = provider.delaySecondsRemaining / 10.0;

      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: 1 - progress, // Reverse progress (filling up as delay counts down)
              strokeWidth: 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, color: Colors.white, size: 16),
                Text(
                  '${provider.delaySecondsRemaining}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Original timer button for active auctions
    final totalSeconds = 30.0;
    final secondsLeft = provider.timeLeft.inSeconds.clamp(0, 30);
    final progress = 1 - (secondsLeft / totalSeconds);
    final nextBidAmount = provider.nextMinimumBid;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
                provider.auctionStatus == "ACTIVE" ? Colors.green : Colors.grey
            ),
          ),
        ),
        InkWell(
          onTap: _canUserBid(provider) ? () {
            print('🔍 Bid button pressed with amount: $nextBidAmount');
            provider.sendBid(nextBidAmount);
            _showBidSuccess('Bid of ${nextBidAmount.toStringAsFixed(2)} NIS sent!');
          } : null,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _canUserBid(provider) ? Colors.green : Colors.grey,
            ),
            child: Icon(
                Icons.gavel,
                color: Colors.white,
                size: 24
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(AuctionProvider provider) {
    return Row(
      children: [
        // WebSocket connection indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: provider.isWebSocketConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        // Auction status indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(provider.auctionStatus),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "ACTIVE":
        return Colors.green;
      case "WAITING":
        return Colors.orange;
      case "COMPLETED":
        return Colors.red;
      case "DELAY": // NEW
        return Colors.orange;
      case "AUCTION_COMPLETED":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAuctionStatusBar(AuctionProvider provider) {
    final progress = _getProgressValue(provider);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(provider.timeLeft.inHours % 24);
    final m = twoDigits(provider.timeLeft.inMinutes % 60);
    final s = twoDigits(provider.timeLeft.inSeconds % 60);

    return Container(
      color: AppColors.cardBackground(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _getTimerText(provider, h, m, s),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(provider.auctionStatus),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    provider.isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: provider.isWebSocketConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isWebSocketConnected ? 'Live' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: provider.isWebSocketConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: provider.isTransitioning
                ? LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            )
                : LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(provider.auctionStatus)),
              minHeight: 8,
            ),
          ),
          // NEW: Show delay message if in delay phase
          if (provider.isInDelayPhase && provider.delayStatusText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.delayStatusText,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to get timer text based on current state
  String _getTimerText(AuctionProvider provider, String h, String m, String s) {
    if (provider.isTransitioning) {
      return "Loading next auction...";
    } else if (provider.isInDelayPhase) {
      return "Auction completed! Next item starting in ${provider.delaySecondsRemaining}s";
    } else if (provider.isTimerActive) {
      return "Time left: $h:$m:$s";
    } else {
      return _getStatusText(provider.auctionStatus);
    }
  }

  // Helper method to get progress value
  double _getProgressValue(AuctionProvider provider) {
    if (provider.isTransitioning) {
      return 0.5; // Show indeterminate progress
    } else if (provider.isInDelayPhase) {
      // Show reverse progress for delay countdown (starts at 1, goes to 0)
      return provider.delaySecondsRemaining > 0 ? (provider.delaySecondsRemaining / 10.0) : 0.0;
    } else if (provider.isTimerActive && provider.timeLeft.inSeconds > 0) {
      return 1 - (provider.timeLeft.inSeconds / 30.0).clamp(0.0, 1.0);
    } else {
      return (provider.auctionStatus == "COMPLETED" ? 1.0 : 0.0);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "ACTIVE":
        return "Currently active - place your bids!";
      case "WAITING":
        return "Waiting for your turn in the auction";
      case "COMPLETED":
        return "Auction completed for this item";
      case "DELAY": // NEW
        return "Preparing next auction...";
      case "AUCTION_COMPLETED":
        return "Entire auction sequence completed";
      default:
        return "Waiting for auction to start";
    }
  }

  Widget _buildImageCarousel(AuctionProvider provider) {
    final images = provider.selectedPost.media.isNotEmpty
        ? provider.selectedPost.media
        : ['assets/images/placeholder.png'];

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
              return ClipRRect(
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
              );
            },
          ),
          if (images.length > 1) _buildImageIndicators(images.length),
          _buildLiveBadge(provider),
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
              color: _selectedImageIndex == index
                  ? AppColors.primaryLightDark(context)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge(AuctionProvider provider) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _getStatusColor(provider.auctionStatus),
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
              _getStatusLabel(provider.auctionStatus),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case "ACTIVE":
        return "Active";
      case "WAITING":
        return "Waiting";
      case "COMPLETED":
        return "Completed";
      case "DELAY":
        return "Delay";
      case "AUCTION_COMPLETED":
        return "Done";
      default:
        return "Unknown";
    }
  }

  Widget _buildCategoryBadge(AuctionProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBackground(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        provider.selectedPost.category,
        style: TextStyle(
          color: AppColors.primaryLightDark(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitle(AuctionProvider provider) {
    return Text(
      provider.selectedPost.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildStats(AuctionProvider provider) {
    // Get unique bidders count (in case same user bids multiple times)
    final uniqueBidders = provider.bids.map((bid) => bid.userName).toSet().length;

    return Row(
      children: [
        Icon(Icons.gavel, size: 16, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Text(
          '$uniqueBidders bidders',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(width: 16),
        Icon(Icons.remove_red_eye, size: 16, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Text(
          '${provider.selectedPost.viewCount} views',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(width: 16),
        // Add real-time bid count indicator
        if (provider.bids.isNotEmpty) ...[
          Icon(Icons.trending_up, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            '${provider.bids.length} bids',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildBidInfo(AuctionProvider provider) {
    final hasActiveBids = provider.bids.isNotEmpty;
    final currentPrice = provider.currentPrice;
    final nextBid = provider.nextMinimumBid;

    print('🔍 BuildBidInfo - Has bids: $hasActiveBids, Current price: $currentPrice, Next bid: $nextBid');

    return Column(
      children: [
        // Main bid info cards
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(8),
                  border: hasActiveBids ? Border.all(
                    color: AppColors.primaryLightDark(context).withOpacity(0.3),
                    width: 1,
                  ) : null,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasActiveBids ? "Highest Bid" : "Starting Price",
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        if (hasActiveBids) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: hasActiveBids
                            ? AppColors.primaryLightDark(context)
                            : AppColors.textSecondary(context),
                      ),
                      child: Text(
                        "NIS ${currentPrice.toStringAsFixed(2)}",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Replace the "Next Bid" container with the circular button
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildNextBidButtonWithTimer(provider),
                  const SizedBox(height: 8),
                  if (provider.isInDelayPhase) ...[
                    Text(
                      "Next Auction",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      "${provider.delaySecondsRemaining}s",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                      ),
                    ),
                  ] else ...[
                    Text(
                      "NIS ${nextBid.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryLightDark(context),
                      ),
                    ),
                    Text(
                      "Next Bid",
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // Real-time bid activity indicator or delay status
        if (provider.isInDelayPhase) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Auction completed • Next item starting in ${provider.delaySecondsRemaining}s",
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else if (hasActiveBids) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Live bidding active • ${provider.bids.length} bids • ${provider.uniqueBiddersCount} bidders",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(AuctionProvider provider) {
    final canBid = _canUserBid(provider);
    final currentPrice = provider.currentPrice;
    final hasActiveBids = provider.bids.isNotEmpty;

    print('🔍 BuildBottomBar - Has bids: $hasActiveBids, Current price: $currentPrice, Can bid: $canBid');

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
                    provider.isInDelayPhase
                        ? "Next Auction"
                        : (hasActiveBids ? "Current Bid" : "Starting Price"),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      if (provider.isInDelayPhase) ...[
                        Text(
                          "${provider.delaySecondsRemaining}s",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ] else ...[
                        Text(
                          "NIS ${currentPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: hasActiveBids
                                ? AppColors.primaryLightDark(context)
                                : AppColors.textPrimary(context),
                          ),
                        ),
                        if (hasActiveBids) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ],
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
                      post: provider.selectedPost.copyWith(
                        // Ensure the bid sheet has the latest pricing info
                        finalPrice: provider.selectedPost.finalPrice,
                        currentBid: provider.selectedPost.currentBid,
                        bids: provider.bids, // Pass the current bids list
                      ),
                      onBidPlaced: (bidAmount) {
                        print('🔍 Placing bid: $bidAmount');
                        provider.sendBid(bidAmount);
                        _showBidSuccess('Bid of ${bidAmount.toStringAsFixed(2)} NIS sent!');
                      },
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
                  _getBidButtonText(provider),
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

  bool _canUserBid(AuctionProvider provider) {
    return provider.auctionStatus == "ACTIVE" &&
        provider.isCurrentPostActive &&
        provider.isTimerActive &&
        !provider.isInDelayPhase && // NEW: Can't bid during delay phase
        !provider.isTransitioning; // NEW: Can't bid during transition
  }

  String _getBidButtonText(AuctionProvider provider) {
    if (provider.isTransitioning) {
      return "Loading Next Auction..."; // NEW
    } else if (provider.isInDelayPhase) {
      return "Preparing Next Auction..."; // NEW
    }

    switch (provider.auctionStatus) {
      case "ACTIVE":
        return provider.isWebSocketConnected ? "Place Bid" : "Connecting...";
      case "WAITING":
        return "Waiting for Turn";
      case "COMPLETED":
        return "Auction Ended";
      case "DELAY": // NEW
        return "Next Auction Starting...";
      case "AUCTION_COMPLETED":
        return "Auction Finished";
      default:
        return "Waiting for Auction";
    }
  }

  void _showBidSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBidsTab(AuctionProvider provider) {
    final allBids = List.from(provider.bids);
    allBids.sort((a, b) => b.time.compareTo(a.time));

    print('🔍 BuildBidsTab - Bids count: ${allBids.length}');
    print('🔍 Provider bids: ${provider.bids.map((b) => '${b.userName}: ${b.amount}').join(', ')}');
    print('🔍 Post bids: ${provider.selectedPost.bids.map((b) => '${b.userName}: ${b.amount}').join(', ')}');

    if (allBids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "No bids yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Starting price: ${provider.selectedPost.startPrice.toStringAsFixed(2)} NIS",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            if (provider.auctionStatus == "ACTIVE")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "This item is active - be the first to bid!",
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else if (provider.auctionStatus == "WAITING")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      "Waiting for this item's turn...",
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else if (provider.isInDelayPhase)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        "Next auction starting in ${provider.delaySecondsRemaining}s...",
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Bid summary header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.isInDelayPhase ? "Auction Completed" : "Live Bidding",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${allBids.length} bids • ${provider.uniqueBiddersCount} bidders",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "NIS ${provider.currentPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bids list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allBids.length,
            itemBuilder: (context, index) {
              final bid = allBids[index];
              final isFirst = index == 0;
              final isRecent = DateTime.now().difference(bid.time).inMinutes < 1;

              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: isFirst
                      ? Border.all(color: AppColors.primaryLightDark(context), width: 2)
                      : isRecent
                      ? Border.all(color: Colors.green.withOpacity(0.5), width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isFirst
                          ? AppColors.primaryLightDark(context).withOpacity(0.3)
                          : AppColors.shadowLight(context),
                      blurRadius: isFirst ? 15 : 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.primaryLightDark(context)
                            : AppColors.lightBackground(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: isFirst ? Colors.white : AppColors.textSecondary(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLightDark(context),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Highest",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (isRecent && !isFirst) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _getTimeAgo(bid.time),
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 12,
                                ),
                              ),
                              if (isRecent) ...[
                                Text(
                                  " • New",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "NIS ${bid.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isFirst
                                ? AppColors.primaryLightDark(context)
                                : AppColors.textPrimary(context),
                          ),
                        ),
                        if (isFirst)
                          Text(
                            provider.isInDelayPhase ? "Winner" : "Leading",
                            style: TextStyle(
                              color: AppColors.primaryLightDark(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "${difference.inSeconds} seconds ago";
    }
  }

  Widget _buildDetailsTab(AuctionProvider provider) {
    final uniqueBidders = provider.bids.map((bid) => bid.userName).toSet().length;
    final currentPriceInfo = provider.bids.isEmpty
        ? "Starting at ${provider.selectedPost.startPrice.toStringAsFixed(2)} NIS"
        : "Current: ${provider.currentPrice.toStringAsFixed(2)} NIS";

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
                "Post Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.category,
                title: "Category",
                value: provider.selectedPost.category,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.people,
                title: "Unique Bidders",
                value: "$uniqueBidders bidders",
                isHighlighted: uniqueBidders > 0,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.gavel,
                title: "Total Bids",
                value: "${provider.bids.length} bids",
                isHighlighted: provider.bids.isNotEmpty,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.remove_red_eye,
                title: "Views",
                value: "${provider.selectedPost.viewCount} views",
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.price_change,
                title: "Starting Price",
                value: "NIS ${provider.selectedPost.startPrice.toStringAsFixed(2)}",
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.trending_up,
                title: "Current Price",
                value: currentPriceInfo,
                isHighlighted: provider.bids.isNotEmpty,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.add_circle_outline,
                title: "Bid Step",
                value: "NIS ${provider.selectedPost.bidStep.toStringAsFixed(2)}",
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.access_time,
                title: "Status",
                value: _getStatusLabel(provider.auctionStatus),
                isHighlighted: provider.auctionStatus == "ACTIVE",
              ),
              if (provider.isTimerActive) ...[
                Divider(color: AppColors.divider(context)),
                _buildInfoRow(
                  icon: Icons.timer,
                  title: "Time Remaining",
                  value: "${provider.timeLeft.inSeconds} seconds",
                  isHighlighted: true,
                ),
              ],
              if (provider.isInDelayPhase) ...[
                Divider(color: AppColors.divider(context)),
                _buildInfoRow(
                  icon: Icons.schedule,
                  title: "Next Auction",
                  value: "Starting in ${provider.delaySecondsRemaining} seconds",
                  isHighlighted: true,
                ),
              ],
              if (provider.isWebSocketConnected) ...[
                Divider(color: AppColors.divider(context)),
                _buildInfoRow(
                  icon: Icons.wifi,
                  title: "Connection",
                  value: "Live updates active",
                  isHighlighted: true,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.selectedPost.description,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
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
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
              icon,
              size: 20,
              color: isHighlighted
                  ? AppColors.primaryLightDark(context)
                  : AppColors.textSecondary(context)
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isHighlighted
                  ? AppColors.primaryLightDark(context)
                  : AppColors.textSecondary(context),
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? AppColors.primaryLightDark(context)
                  : AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab(AuctionProvider provider) {
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
                "Auction Rules",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                number: 1,
                title: "Sequential Order",
                description: "Items are auctioned one by one in a predetermined order.",
              ),
              _buildRuleItem(
                number: 2,
                title: "Timer Reset",
                description: "When a new bid is placed, the timer resets to 30 seconds.",
              ),
              _buildRuleItem(
                number: 3,
                title: "Auction Delay", // NEW
                description: "After each auction ends, there's a 10-second delay before the next item starts.",
              ),
              _buildRuleItem(
                number: 4,
                title: "Auto Progression",
                description: "When time expires, the auction automatically moves to the next item after the delay.",
              ),
              _buildRuleItem(
                number: 5,
                title: "Minimum Bid",
                description: "Minimum bid increment is ${provider.selectedPost.bidStep.toStringAsFixed(2)} NIS above the current highest bid.",
              ),
              _buildRuleItem(
                number: 6,
                title: "Winner Commitment",
                description: "The winning bidder must complete the purchase within 48 hours.",
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.cardBackground(context), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}