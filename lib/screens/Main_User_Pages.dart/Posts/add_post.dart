import 'dart:io';
import 'package:application/API_Service/api.dart';
import 'package:application/constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> descriptionPoints = [];
  final TextEditingController startPriceController = TextEditingController();
  final TextEditingController bidStepController = TextEditingController();
  List<XFile> images = [];
  bool isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.directions_car,
      "label": "category_cars".tr(),
      "color": Colors.blue,
    },
    {
      "icon": Icons.phone_android,
      "label": "category_phones".tr(),
      "color": Colors.green,
    },
    {
      "icon": Icons.laptop_mac,
      "label": "category_laptops".tr(),
      "color": Colors.purple,
    },
    {
      "icon": Icons.home,
      "label": "category_real_estate".tr(),
      "color": Colors.orange,
    },
    {
      "icon": Icons.watch,
      "label": "category_watches".tr(),
      "color": Colors.red,
    },
    {
      "icon": Icons.chair,
      "label": "category_furniture".tr(),
      "color": Colors.brown,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    startPriceController.dispose();
    bidStepController.dispose();
    super.dispose();
  }

  void pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? picked = await picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        if (images.length + picked.length > 5) {
          images.addAll(picked.take(5 - images.length));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 images allowed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.warning(context),
            ),
          );
        } else {
          images.addAll(picked);
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void addPointToDescription() {
    if (descriptionController.text.isNotEmpty) {
      setState(() {
        descriptionPoints.add(descriptionController.text);
        descriptionController.clear();
      });
      Future.delayed(Duration(milliseconds: 100), () {
        if (_descriptionScrollController.hasClients) {
          _descriptionScrollController.animateTo(
            _descriptionScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void removeDescriptionPoint(int index) {
    setState(() {
      descriptionPoints.removeAt(index);
    });
  }

  void submitPost() async {
    if (!validateForm()) return;

    setState(() => isSubmitting = true);

    try {
      final api = ApiService();

      // ✅ 1. استدعاء API لجلب auction المناسب
      final auctionData = await api.getAuctionByCategoryAndStatus(
        category: selectedCategory!.toUpperCase().replaceAll(" ", "_"),
        status: "WAITING",
      );

      if (auctionData == null || auctionData['id'] == null) {
        throw Exception('Failed to fetch auction');
      }

      final auctionId = auctionData['id'];

      final userData = await api.getCurrentUser();
      if (userData == null) {
        throw Exception('Failed to fetch auction1');
      }

      final userid = userData?['id'];

      final postJson = {
        "title": titleController.text,
        "description": descriptionPoints.join(", "),
        "startPrice": double.parse(startPriceController.text),
        "category": selectedCategory!.toUpperCase().replaceAll(" ", "_"),
        "bidStep": double.parse(bidStepController.text),
        "status": "WAITING",
        "user": {"id": userid}, // عدّل الـ ID لاحقاً حسب المستخدم الفعلي
        "auction": {"id": auctionId},
      };
      print("${postJson}");

      final imageFiles = images.map((xfile) => File(xfile.path)).toList();

      await api.uploadPostWithImages(
        postJson: postJson,
        imageFiles: imageFiles,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("تم النشر"),
                content: const Text("تم رفع المنشور بنجاح"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      resetForm();
                    },
                    child: const Text("موافق"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في رفع المنشور'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  bool validateForm() {
    String errorMessage = '';

    if (selectedCategory == null) {
      errorMessage = 'Please select a category';
    } else if (titleController.text.isEmpty) {
      errorMessage = 'Please enter a title';
    } else if (descriptionPoints.isEmpty) {
      errorMessage = 'Please add at least one description point';
    } else if (startPriceController.text.isEmpty) {
      errorMessage = 'Please enter a starting price';
    } else if (bidStepController.text.isEmpty) {
      errorMessage = 'Please enter a bid step';
    } else if (images.isEmpty) {
      errorMessage = 'Please add at least one image';
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error(context),
        ),
      );
      return false;
    }

    return true;
  }

  void resetForm() {
    setState(() {
      selectedCategory = null;
      titleController.clear();
      descriptionController.clear();
      descriptionPoints.clear();
      startPriceController.clear();
      bidStepController.clear();
      images.clear();
    });
  }

  final ScrollController _descriptionScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        title: Text(
          "create_auction".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        backgroundColor: AppColors.cardBackground(context),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.restart_alt,
              color: AppColors.textSecondary(context),
            ),
            onPressed: resetForm,
            tooltip: "reset_form".tr(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.subtleGradient(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Progress Indicator
                  LinearProgressIndicator(
                    value: _calculateProgress(),
                    backgroundColor: AppColors.progressBackground(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryLightDark(context),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "form_hint".tr(),
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category Selector
                  _buildSectionTitle("choose_category".tr(), Icons.category),
                  const SizedBox(height: 16),

                  _buildCategorySection(),

                  const SizedBox(height: 24),

                  // Item Details
                  _buildSectionTitle("item_details".tr(), Icons.description),
                  const SizedBox(height: 8),

                  _buildItemDetailsSection(),

                  const SizedBox(height: 24),

                  // Images
                  _buildSectionTitle("upload_images".tr(), Icons.image),
                  const SizedBox(height: 8),
                  Text(
                    "upload_note".tr(),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildImageSection(screenWidth),

                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryLightDark(context)),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  categories.map((category) {
                    final isSelected = selectedCategory == category['label'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category['label'];
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? category['color'].withOpacity(0.9)
                                  : AppColors.getCategoryChipBackground(
                                    context,
                                    category['color'],
                                  ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                isSelected
                                    ? category['color']
                                    : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: category['color'].withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'],
                              color:
                                  isSelected ? Colors.white : category['color'],
                            ),
                            SizedBox(width: 8),
                            Text(
                              category['label'],
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : category['color'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                hintText: 'Enter a descriptive title',
                hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                prefixIcon: Icon(
                  Icons.title,
                  color: AppColors.textSecondary(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.divider(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.divider(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primaryLightDark(context),
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                filled: true,
                fillColor: AppColors.inputFieldBackground(context),
              ),
            ),

            const SizedBox(height: 20),

            // Description Points
            Text(
              "description_points".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildDescriptionSection(),

            const SizedBox(height: 20),

            // Pricing
            Text(
              "pricing_info".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildPricingFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      children: [
        Container(
          height: descriptionPoints.isEmpty ? 60 : 120,
          decoration: BoxDecoration(
            color: AppColors.inputFieldBackground(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider(context)),
          ),
          child:
              descriptionPoints.isEmpty
                  ? Center(
                    child: Text(
                      "no_description".tr(),
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                  : ListView.separated(
                    controller: _descriptionScrollController,
                    padding: EdgeInsets.all(8),
                    itemCount: descriptionPoints.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          height: 1,
                          color: AppColors.divider(context),
                        ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryLightDark(context),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                descriptionPoints[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error(context),
                              ),
                              onPressed: () => removeDescriptionPoint(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: descriptionController,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: "add_description".tr(),
                  hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.divider(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.divider(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.primaryLightDark(context),
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.inputFieldBackground(context),
                  prefixIcon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                onSubmitted: (_) => addPointToDescription(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLightDark(context).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: addPointToDescription,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingFields() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: startPriceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              labelText: "start_price".tr(),
              labelStyle: TextStyle(color: AppColors.textSecondary(context)),
              prefixIcon: Icon(
                Icons.attach_money,
                color: AppColors.textSecondary(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryLightDark(context),
                ),
              ),
              filled: true,
              fillColor: AppColors.inputFieldBackground(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: bidStepController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              labelText: "bid_step".tr(),
              labelStyle: TextStyle(color: AppColors.textSecondary(context)),
              prefixIcon: Icon(
                Icons.trending_up,
                color: AppColors.textSecondary(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryLightDark(context),
                ),
              ),
              filled: true,
              fillColor: AppColors.inputFieldBackground(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          images.isEmpty
              ? GestureDetector(
                onTap: pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.imageUploadBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.divider(context),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppColors.textSecondary(context),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "tap_add_images".tr(),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : Container(
                height: 200,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 5 : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount:
                      images.length < 5 ? images.length + 1 : images.length,
                  itemBuilder: (context, index) {
                    if (index == images.length && images.length < 5) {
                      return GestureDetector(
                        onTap: pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.imageUploadBackground(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.divider(context),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight(context),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(images[index].path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.error(
                                  context,
                                ).withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightDark(
                                  context,
                                ).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "main_image".tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "main_image_note".tr(),
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: AppColors.primaryGradient(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLightDark(context).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "creating_auction".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "post_auction".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  double _calculateProgress() {
    int completedFields = 0;
    int totalFields = 5;

    if (selectedCategory != null) completedFields++;
    if (titleController.text.isNotEmpty) completedFields++;
    if (descriptionPoints.isNotEmpty) completedFields++;
    if (startPriceController.text.isNotEmpty &&
        bidStepController.text.isNotEmpty)
      completedFields++;
    if (images.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }
}
