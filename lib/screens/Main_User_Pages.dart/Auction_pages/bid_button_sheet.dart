import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:application/models/post_2.dart';
import 'package:application/constants/app_colors.dart';

class BidBottomSheet extends StatefulWidget {
  final Post post;
  final Function(double) onBidPlaced;

  const BidBottomSheet({
    super.key,
    required this.post,
    required this.onBidPlaced,
  });

  @override
  State<BidBottomSheet> createState() => _BidBottomSheetState();
}

class _BidBottomSheetState extends State<BidBottomSheet> {
  final TextEditingController _bidController = TextEditingController();
  final FocusNode _bidFocusNode = FocusNode();

  double _selectedBidAmount = 0;
  bool _isCustomBid = false;
  bool _isValidBid = false;
  String? _errorMessage;

  // Quick bid options (multiples of bid step)
  late List<double> _quickBidOptions;

  @override
  void initState() {
    super.initState();
    _debugPostData(); // Add debugging
    _initializeBidOptions();
    _bidController.addListener(_onBidTextChanged);
  }

  @override
  void dispose() {
    _bidController.dispose();
    _bidFocusNode.dispose();
    super.dispose();
  }

  // ADD debugging method
  void _debugPostData() {
    print('🔍 === BID BOTTOM SHEET DEBUG ===');
    print('Post ID: ${widget.post.id}');
    print('Start Price: ${widget.post.startPrice}');
    print('Final Price: ${widget.post.finalPrice}');
    print('Current Bid: ${widget.post.currentBid}');
    print('Bid Step: ${widget.post.bidStep}');
    print('Status: ${widget.post.status}');
    print('Calculated Current Price: ${_getCurrentPrice()}');
    print('Calculated Minimum Bid: ${_getMinimumBid()}');
    print('================================');
  }

  void _initializeBidOptions() {
    final currentPrice = _getCurrentPrice();
    final bidStep = widget.post.bidStep;
    final double finalPrice = widget.post.finalPrice ?? 0.0;

    print('🔍 Initializing bid options:');
    print('   - Start Price: ${widget.post.startPrice}');
    print('   - Final Price: ${widget.post.finalPrice}');
    print('   - Current Bid: ${widget.post.currentBid}');
    print('   - Calculated Current Price: $currentPrice');
    print('   - Bid Step: $bidStep');

    // Generate quick bid options
    _quickBidOptions = [
      // This is the key change:
      // Only include `currentPrice` in the list if `finalPrice` is 0 or less.
      if (finalPrice <= 0) currentPrice,

      // The rest of the options are for future bids
      currentPrice + bidStep,
      currentPrice + (bidStep * 2),
      currentPrice + (bidStep * 3),
      currentPrice + (bidStep * 5),
    ];

    // Set default selected amount to minimum bid
    _selectedBidAmount = _quickBidOptions[0];
    _validateBidAmount(_selectedBidAmount);

    print('🔍 Generated bid options: $_quickBidOptions');
    print('🔍 Default selected amount: $_selectedBidAmount');
  }

  // FIXED: Use consistent null-aware operator logic like in AuctionDetailPage
  double _getCurrentPrice() {
    // Use the same logic as AuctionDetailPage for consistency
    if (widget.post.finalPrice != null && widget.post.finalPrice! > 0) {
      return widget.post.finalPrice!;
    }

    // Otherwise, use currentBid if it's valid
    if (widget.post.currentBid != null && widget.post.currentBid! > 0) {
      return widget.post.currentBid!;
    }

    // Otherwise, fall back to the startPrice

    print('🔍 _getCurrentPrice calculation:');
    print('   - finalPrice: ${widget.post.finalPrice}');
    print('   - currentBid: ${widget.post.currentBid}');
    print('   - startPrice: ${widget.post.startPrice}');
    return widget.post.startPrice;
  }

  double _getMinimumBid() {
    final minimum = _getCurrentPrice() + widget.post.bidStep;
    print('🔍 _getMinimumBid: ${_getCurrentPrice()} + ${widget.post.bidStep} = $minimum');
    return minimum;
  }

  // Enhanced validation with better debugging
  void _validateBidAmount(double amount) {
    final minimumBid = _getMinimumBid();
    final currentPrice = _getCurrentPrice();

    print('🔍 Validating bid: $amount');
    print('   - Current Price: $currentPrice');
    print('   - Minimum Required: $minimumBid');
    print('   - Bid Step: ${widget.post.bidStep}');

    setState(() {
      if(widget.post.finalPrice == 0.0 && amount== widget.post.startPrice){
        _isValidBid = true;
      } else if (amount < minimumBid) {
        _isValidBid = false;
        _errorMessage = 'Minimum bid is ${minimumBid.toStringAsFixed(2)} NIS';
        print('❌ Bid validation failed: $amount < $minimumBid');
      } else if (amount <= 0) {
        _isValidBid = false;
        _errorMessage = 'Bid amount must be greater than 0';
        print('❌ Bid validation failed: Amount must be > 0');
      } else {
        _isValidBid = true;
        _errorMessage = null;
        print('✅ Bid validation passed: $amount >= $minimumBid');
      }
    });
  }

  void _onBidTextChanged() {
    final text = _bidController.text;
    if (text.isEmpty) {
      setState(() {
        _isCustomBid = false;
        _selectedBidAmount = _quickBidOptions[0];
        _validateBidAmount(_selectedBidAmount);
      });
      return;
    }

    final amount = double.tryParse(text);
    if (amount != null) {
      setState(() {
        _isCustomBid = true;
        _selectedBidAmount = amount;
        _validateBidAmount(amount);
      });
    }
  }

  void _selectQuickBid(double amount) {
    print('🔍 Selected quick bid: $amount');
    setState(() {
      _selectedBidAmount = amount;
      _isCustomBid = false;
      _bidController.clear();
      _validateBidAmount(amount);
    });
    _bidFocusNode.unfocus();
  }

  void _placeBid() {
    if (!_isValidBid) {
      _showError(_errorMessage ?? 'Invalid bid amount');
      return;
    }

    print('💰 Placing bid: ${_selectedBidAmount.toStringAsFixed(2)} NIS');
    print('🔍 Final validation before sending:');
    print('   - Selected Amount: $_selectedBidAmount');
    print('   - Current Price: ${_getCurrentPrice()}');
    print('   - Minimum Required: ${_getMinimumBid()}');
    print('   - Is Valid: $_isValidBid');

    // Call the callback with the total bid amount
    widget.onBidPlaced(_selectedBidAmount);

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCurrentPriceInfo() {
    final currentPrice = _getCurrentPrice();
    final minimumBid = _getMinimumBid();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Highest Bid:',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              Text(
                'NIS ${currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Next Bid:',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              Text(
                'NIS ${minimumBid.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.primaryLightDark(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Show starting price info if no bids yet
          if (currentPrice == widget.post.startPrice) ...[
            const SizedBox(height: 4),
            Text(
              '(Starting at ${widget.post.startPrice.toStringAsFixed(2)} NIS - No bids yet)',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // DEBUG INFO (remove in production)
          if (currentPrice != widget.post.startPrice) ...[
            const SizedBox(height: 4),
            Text(
              'DEBUG: finalPrice=${widget.post.finalPrice}, currentBid=${widget.post.currentBid}',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Place Your Bid',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Current price info - Using the new method
          _buildCurrentPriceInfo(),
          const SizedBox(height: 20),

          // Quick bid options
          Text(
            'Quick Bid Options:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickBidOptions.map((amount) {
              final isSelected = !_isCustomBid && _selectedBidAmount == amount;
              return GestureDetector(
                onTap: () => _selectQuickBid(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLightDark(context)
                        : AppColors.lightBackground(context),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLightDark(context)
                          : AppColors.divider(context),
                    ),
                  ),
                  child: Text(
                    'NIS ${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Custom bid input
          Text(
            'Or Enter Custom Amount:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _bidController,
            focusNode: _bidFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Bid Amount (NIS)',
              hintText: 'Enter amount...',
              prefixText: 'NIS ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryLightDark(context),
                  width: 2,
                ),
              ),
              errorText: _isCustomBid ? _errorMessage : null,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            onSubmitted: (value) {
              if (_isValidBid) {
                _placeBid();
              }
            },
          ),
          const SizedBox(height: 24),

          // Selected bid summary
          if (_selectedBidAmount > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isValidBid
                    ? AppColors.primaryLightDark(context).withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isValidBid
                      ? AppColors.primaryLightDark(context)
                      : Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Bid:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isValidBid
                          ? AppColors.primaryLightDark(context)
                          : Colors.red,
                    ),
                  ),
                  Text(
                    'NIS ${_selectedBidAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isValidBid
                          ? AppColors.primaryLightDark(context)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Place bid button
          ElevatedButton(
            onPressed: _isValidBid ? _placeBid : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValidBid
                  ? AppColors.primaryLightDark(context)
                  : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isValidBid ? 2 : 0,
            ),
            child: Text(
              _isValidBid
                  ? 'Place Bid - NIS ${_selectedBidAmount.toStringAsFixed(2)}'
                  : 'Enter Valid Bid Amount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}