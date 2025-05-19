import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:application/models/post.dart';

class DetailsPostPage extends StatefulWidget {
  final Post post;

  const DetailsPostPage({super.key, required this.post});

  @override
  State<DetailsPostPage> createState() => _DetailsPostPageState();
}

class _DetailsPostPageState extends State<DetailsPostPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController();

  bool _autoBidEnabled = false;
  TextEditingController _limitController = TextEditingController();
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
  );

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.tealAccent : Colors.teal;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtleColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildContent(
                      context,
                      accentColor,
                      cardColor,
                      subtleColor,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color accentColor,
    Color cardColor,
    Color subtleColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPullHandle(),
        _buildImageCarousel(accentColor),
        Transform.translate(
          offset: const Offset(0, 0),
          child: _buildPostDetails(
            context,
            accentColor,
            cardColor,
            subtleColor,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPullHandle() => Center(
    child: Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );

  Widget _buildImageCarousel(Color accentColor) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.post.media.length,
            onPageChanged:
                (index) => setState(() => _currentImageIndex = index),
            itemBuilder:
                (context, index) => Hero(
                  tag: 'post-image-${widget.post.media[index]}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FullImagePage(
                                  imagePath: widget.post.media[index],
                                ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.post.media[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.post.media.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color:
                      _currentImageIndex == index
                          ? accentColor
                          : Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle, // 👈 هذا أهم تعديل
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    IconData icon,
    VoidCallback onTap, {
    bool left = false,
  }) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: left ? 8 : null,
      right: left ? null : 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 18)),
        ),
      ),
    );
  }

  Widget _buildPostDetails(
    BuildContext context,
    Color accentColor,
    Color cardColor,
    Color subtleColor,
    bool isDark,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(accentColor, subtleColor, textTheme, isDark),
          _buildAnimatedDivider(context, accentColor),
          _buildDescription(accentColor, isDark),
          _buildPricingGlass(accentColor, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTitleSection(
    Color accentColor,
    Color subtleColor,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.post.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          accentColor,
                        ],
                      ).createShader(bounds),
                  child: Text(
                    widget.post.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDivider(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder:
            (context, value, child) => Container(
              height: 1,
              width: MediaQuery.of(context).size.width * value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    accentColor.withOpacity(0.3),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDescription(Color accentColor, bool isDark) {
    final points =
        widget.post.description.split(',').map((e) => e.trim()).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(points.length, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + index * 100),
              builder:
                  (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                points[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color:
                                      isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            );
          }),
        ],
      ),
    );
  }

Widget _buildPricingGlass(Color accentColor, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // السعر والـ Bid Step
              Row(
                children: [
                  Expanded(
                    child: _priceTile(
                      Icons.attach_money_rounded,
                      'Start Price',
                      '${widget.post.startPrice} NIS',
                      isDark,
                      accentColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  Expanded(
                    child: _priceTile(
                      Icons.trending_up_rounded,
                      'Bid Step',
                      '${widget.post.bidStep} NIS',
                      isDark,
                      accentColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              const SizedBox(height: 16),

              _priceTile(
                Icons.gavel_rounded,
                'Post # on Auction',
                '#${widget.post.numberOfOnAuction}',
                isDark,
                accentColor,
                centerAlign: true,
              ),

              const SizedBox(height: 24),

              // Auto Bid Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.autorenew_rounded, color: accentColor),
                      const SizedBox(width: 10),
                      Text(
                        'Auto Bid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _autoBidEnabled,
                    activeColor: accentColor,
                    onChanged: (value) {
                      setState(() {
                        _autoBidEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              if (_autoBidEnabled) ...[
                const SizedBox(height: 16),

                // Auto Bid Limit Input
                TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Auto Bid Limit (NIS)',
                    labelStyle: TextStyle(color: accentColor),
                    prefixIcon: Icon(Icons.price_change_outlined, color: accentColor),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final limit = _limitController.text.trim();
                      if (limit.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Auto bid limit set to $limit NIS'),
                            backgroundColor: accentColor,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Limit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _priceTile(
    IconData icon,
    String label,
    String value,
    bool isDark,
    Color accentColor, {
    bool centerAlign = false,
  }) {
    return Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              centerAlign ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: accentColor.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }


}

class FullImagePage extends StatelessWidget {
  final String imagePath;

  const FullImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Hero(
                tag: imagePath,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),

          // زر الإغلاق
          Positioned(
            top: 40, // ممكن تعدله حسب تصميمك
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
