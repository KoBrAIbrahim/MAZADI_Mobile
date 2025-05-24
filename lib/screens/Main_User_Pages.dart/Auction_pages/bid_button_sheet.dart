import 'package:application/models/post.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BidBottomSheet extends StatefulWidget {
  final VoidCallback onBidPlaced;
  final Post post;

  const BidBottomSheet({
    Key? key,
    required this.onBidPlaced,
    required this.post,
  }) : super(key: key);

  @override
  State<BidBottomSheet> createState() => _BidBottomSheetState();
}

class _BidBottomSheetState extends State<BidBottomSheet> {
  String? selectedBidValue;
  final TextEditingController _customBidController = TextEditingController();

  @override
  void dispose() {
    _customBidController.dispose();
    super.dispose();
  }

  void _confirmBid() {
    widget.onBidPlaced();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentBid = widget.post.currentBid;
    final bidStep = widget.post.bid_step;
    final minBid = currentBid + bidStep;

    final bidOptions = [
      minBid,
      currentBid + bidStep * 2,
      currentBid + bidStep * 3,
      currentBid + bidStep * 4,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          Text(
            'place_bid'.tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildBidSummary(),
          const SizedBox(height: 20),
          Text(
            'choose_bid_value'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children:
                bidOptions
                    .map(
                      (bid) => _buildBidOption("NIS ${bid.toStringAsFixed(2)}"),
                    )
                    .toList(),
          ),
          const SizedBox(height: 20),
          _buildCustomBidField(),
          const SizedBox(height: 20),
          _buildWarning(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _confirmBid,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'confirm_bid'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidSummary() {
    final currentBid = widget.post.currentBid;
    final bidStep = widget.post.bid_step;
    final minBid = currentBid + bidStep;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
      onSelected: (_) {
        setState(() {
          selectedBidValue = value;
          _customBidController.clear();
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.teal.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.teal : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomBidField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _customBidController,
        decoration: InputDecoration(
          hintText: 'custom_value'.tr(),
          prefixIcon: const Icon(
            Icons.monetization_on_outlined,
            color: Colors.teal,
          ),
          suffixText: "NIS",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (_) {
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
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'bid_warning'.tr(),
              style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
