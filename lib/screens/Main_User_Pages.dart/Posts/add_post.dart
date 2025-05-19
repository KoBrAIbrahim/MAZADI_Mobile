import 'dart:io';
import 'package:application/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';


class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> with SingleTickerProviderStateMixin {
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
    {"icon": Icons.directions_car, "label": "Cars", "color": Colors.blue},
    {"icon": Icons.phone_android, "label": "Phones", "color": Colors.green},
    {"icon": Icons.laptop_mac, "label": "Laptops", "color": Colors.purple},
    {"icon": Icons.home, "label": "Real Estate", "color": Colors.orange},
    {"icon": Icons.watch, "label": "Watches", "color": Colors.red},
    {"icon": Icons.chair, "label": "Furniture", "color": Colors.brown},
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
          // Limit to 5 images
          images.addAll(picked.take(5 - images.length));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 5 images allowed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.amber.shade800,
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
      // Scroll to bottom of description list
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

  void submitPost() {
    if (!validateForm()) return;

    setState(() {
      isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isSubmitting = false;
      });
      // Show success
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Success'),
            ],
          ),
          content: Text('Your post has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset form
                resetForm();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
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
          backgroundColor: Colors.red.shade800,
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final cardBackground = isDarkMode 
        ? Color(0xFF1E1E1E) 
        : Colors.white;
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Auction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: resetForm,
            tooltip: 'Reset form',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode 
                  ? [Color(0xFF121212), Color(0xFF262626)]
                  : [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
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
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Complete the form to create your auction',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Category Selector
                  _buildSectionTitle('Choose Category', Icons.category),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                          // Category chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: categories.map((category) {
                              final isSelected = selectedCategory == category['label'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category['label'];
                                  });
                                  // Add haptic feedback
                                  HapticFeedback.lightImpact();
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? category['color'].withOpacity(0.9) 
                                        : category['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: isSelected 
                                          ? category['color'] 
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected 
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
                                        color: isSelected 
                                            ? Colors.white 
                                            : category['color'],
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        category['label'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : category['color'],
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
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  _buildSectionTitle('Item Details', Icons.description),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                          TextField(
                            controller: titleController,
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter a descriptive title',
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              filled: true,
                              fillColor: isDarkMode 
                                  ? Colors.grey.shade900 
                                  : Colors.grey.shade50,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Description
                          Text(
                            'Description Points',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: descriptionPoints.isEmpty ? 60 : 120,
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.shade900 
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: descriptionPoints.isEmpty
                                ? Center(
                                    child: Text(
                                      'No description points added yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: _descriptionScrollController,
                                    padding: EdgeInsets.all(8),
                                    itemCount: descriptionPoints.length,
                                    separatorBuilder: (context, index) => Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, 
                                                color: AppColors.primary, size: 18),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                descriptionPoints[index],
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, size: 18),
                                              color: Colors.red.shade400,
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
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: 'Add a description point',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode 
                                        ? Colors.grey.shade900 
                                        : Colors.grey.shade50,
                                    prefixIcon: Icon(Icons.add_circle_outline),
                                  ),
                                  onSubmitted: (_) => addPointToDescription(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
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
                          
                          const SizedBox(height: 20),
                          
                          // Price Details
                          Text(
                            'Pricing Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: startPriceController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Start Price',
                                    prefixIcon: Icon(Icons.attach_money),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode 
                                        ? Colors.grey.shade900 
                                        : Colors.grey.shade50,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: bidStepController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Bid Step',
                                    prefixIcon: Icon(Icons.trending_up),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode 
                                        ? Colors.grey.shade900 
                                        : Colors.grey.shade50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Images
                  _buildSectionTitle('Upload Images', Icons.image),
                  const SizedBox(height: 8),
                  Text(
                    'Add up to 5 high-quality images of your item',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image grid
                        images.isEmpty
                            ? GestureDetector(
                                onTap: pickImages,
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? Colors.grey.shade900 
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
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
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to add images',
                                          style: TextStyle(
                                            color: Colors.grey,
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
                                  itemCount: images.length < 5 ? images.length + 1 : images.length,
                                  itemBuilder: (context, index) {
                                    if (index == images.length && images.length < 5) {
                                      return GestureDetector(
                                        onTap: pickImages,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode 
                                                ? Colors.grey.shade900 
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.3),
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.add_photo_alternate,
                                              size: 32,
                                              color: Colors.grey,
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
                                                color: Colors.black.withOpacity(0.1),
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
                                                color: Colors.red.withOpacity(0.8),
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
                                        // Show if main image
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
                                                color: AppColors.primary.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Main',
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
                              '* First image will be used as the main image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
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
                      child: isSubmitting
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
                                  'Creating Auction...',
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
                                  'Post Auction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
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
        Icon(icon, size: 20, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _calculateProgress() {
    int completedFields = 0;
    int totalFields = 5;
    
    if (selectedCategory != null) completedFields++;
    if (titleController.text.isNotEmpty) completedFields++;
    if (descriptionPoints.isNotEmpty) completedFields++;
    if (startPriceController.text.isNotEmpty && bidStepController.text.isNotEmpty) completedFields++;
    if (images.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }
}