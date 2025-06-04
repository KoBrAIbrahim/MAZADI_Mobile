import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:application/models/post_2.dart';

class BidBottomSheet extends StatefulWidget {
  final Post post;
  final Function(double)? onBidPlaced; // Add WebSocket bid callback

  const BidBottomSheet({
    Key? key,
    required this.post,
    this.onBidPlaced, // Make it optional for backwards compatibility
  }) : super(key: key);

  @override
  State<BidBottomSheet> createState() => _BidBottomSheetState();
}

class _BidBottomSheetState extends State<BidBottomSheet> {
  String? selectedBidValue;
  final TextEditingController _customBidController = TextEditingController();
  bool _isPlacingBid = false; // Add loading state

  @override
  void dispose() {
    _customBidController.dispose();
    super.dispose();
  }

  double? _getSelectedBidAmount() {
    if (selectedBidValue != null) {
      // Extract number from "NIS XX.XX" format
      String numberString = selectedBidValue!.replaceAll('NIS ', '');
      return double.tryParse(numberString);
    } else if (_customBidController.text.isNotEmpty) {
      return double.tryParse(_customBidController.text);
    }
    return null;
  }

  bool _isValidBid(double bidAmount) {
    final post = widget.post;
    final currentBid = post.finalPrice ?? post.startPrice;
    final minBid = currentBid + post.bidStep;
    return bidAmount >= minBid;
  }

  void _confirmBid() async {
    final bidAmount = _getSelectedBidAmount();

    if (bidAmount == null) {
      _showError('Please select or enter a bid amount');
      return;
    }

    if (!_isValidBid(bidAmount)) {
      final post = widget.post;
      final currentBid = post.finalPrice ?? post.startPrice;
      final minBid = currentBid + post.bidStep;
      _showError('Bid must be at least NIS ${minBid.toStringAsFixed(2)}');
      return;
    }

    setState(() {
      _isPlacingBid = true;
    });

    try {
      if (widget.onBidPlaced != null) {
        // Use WebSocket to place bid
        widget.onBidPlaced!(bidAmount);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bid of NIS ${bidAmount.toStringAsFixed(2)} placed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Fallback - you can add HTTP API call here if needed
        print('No WebSocket callback provided, bid amount: $bidAmount');
      }

      // Close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      _showError('Failed to place bid: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingBid = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final currentBid = post.finalPrice ?? post.startPrice;
    final bidStep = post.bidStep;
    final minBid = currentBid + bidStep;

    final bidOptions = [
      minBid,
      currentBid + bidStep * 2,
      currentBid + bidStep * 3,
      currentBid + bidStep * 4,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              Text(
                'place_bid'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              // WebSocket connection indicator
              if (widget.onBidPlaced != null) ...[
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
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildBidSummary(currentBid, bidStep),
          const SizedBox(height: 20),
          Text(
            'choose_bid_value'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: bidOptions
                .map((bid) =>
                _buildBidOption("NIS ${bid.toStringAsFixed(2)}"))
                .toList(),
          ),
          const SizedBox(height: 20),
          _buildCustomBidField(),
          const SizedBox(height: 20),
          _buildWarning(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isPlacingBid ? null : _confirmBid,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: _isPlacingBid
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: _isPlacingBid
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'placing_bid'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
                : Text(
              'confirm_bid'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _isPlacingBid ? null : () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: _isPlacingBid
                    ? Colors.grey
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidSummary(double currentBid, double bidStep) {
    final minBid = currentBid + bidStep;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_bid'.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "NIS ${currentBid.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'min_bid'.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "NIS ${minBid.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidOption(String value) {
    final isSelected = selectedBidValue == value;
    return ChoiceChip(
      label: Text(value),
      selected: isSelected,
      onSelected: _isPlacingBid ? null : (_) {
        setState(() {
          selectedBidValue = value;
          _customBidController.clear();
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomBidField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isPlacingBid
              ? Colors.grey.shade300
              : Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _customBidController,
        enabled: !_isPlacingBid,
        decoration: InputDecoration(
          hintText: 'custom_value'.tr(),
          prefixIcon: Icon(
            Icons.monetization_on_outlined,
            color: _isPlacingBid
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
          ),
          suffixText: "NIS",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: _isPlacingBid ? null : (_) {
          setState(() {
            selectedBidValue = null;
          });
        },
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.onBidPlaced != null
                  ? 'bid_warning_live'.tr() // Add this translation: "Bids are placed instantly via live connection"
                  : 'bid_warning'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}