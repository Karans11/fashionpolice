import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:math';
import '../../models/clothing_item_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({Key? key}) : super(key: key);

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();
  
  Uint8List? _imageBytes;
  String _selectedCategory = 'Top';
  List<String> _selectedColors = [];
  List<String> _selectedOccasions = [];
  bool _isUploading = false;

  final Map<String, Map<String, dynamic>> _categories = {
    'Top': {
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'examples': ['T-shirt', 'Blouse', 'Tank Top', 'Sweater'],
    },
    'Bottom': {
      'icon': Icons.fitness_center,
      'color': Colors.indigo,
      'examples': ['Jeans', 'Skirt', 'Shorts', 'Leggings'],
    },
    'Dress': {
      'icon': Icons.woman,
      'color': Colors.teal,
      'examples': ['Casual Dress', 'Formal Dress', 'Maxi Dress'],
    },
    'Outerwear': {
      'icon': Icons.ac_unit,
      'color': Colors.orange,
      'examples': ['Jacket', 'Coat', 'Blazer', 'Cardigan'],
    },
    'Shoes': {
      'icon': Icons.directions_walk,
      'color': Colors.brown,
      'examples': ['Sneakers', 'Heels', 'Flats', 'Boots'],
    },
    'Accessories': {
      'icon': Icons.watch,
      'color': Colors.green,
      'examples': ['Bag', 'Jewelry', 'Hat', 'Scarf'],
    },
  };

  final Map<String, Color> _colorOptions = {
    'Black': Colors.black,
    'White': Colors.white,
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Brown': Colors.brown,
    'Gray': Colors.grey,
    'Navy': Colors.indigo.shade900,
    'Beige': Color(0xFFF5F5DC),
    'Maroon': Colors.red.shade900,
  };

  final Map<String, Map<String, dynamic>> _occasions = {
    'Casual': {'icon': Icons.weekend, 'color': Colors.blue},
    'Formal': {'icon': Icons.business_center, 'color': Colors.grey.shade800},
    'Party': {'icon': Icons.celebration, 'color': Colors.purple},
    'Work': {'icon': Icons.work, 'color': Colors.indigo},
    'Date': {'icon': Icons.favorite, 'color': Colors.red},
    'Sports': {'icon': Icons.fitness_center, 'color': Colors.orange},
    'Home': {'icon': Icons.home, 'color': Colors.green},
    'Beach': {'icon': Icons.beach_access, 'color': Colors.cyan},
  };

  String _generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           random.nextInt(1000).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildColorSection(),
              const SizedBox(height: 24),
              _buildOccasionSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_a_photo, color: Colors.pink, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _imageBytes != null ? Colors.pink : Colors.pink.shade200,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _imageBytes != null ? Colors.transparent : Colors.pink.shade50,
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 60,
                          color: Colors.pink.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add your clothing photo',
                          style: TextStyle(
                            color: Colors.pink.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade100,
                      foregroundColor: Colors.pink.shade700,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple.shade700,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final categoryName = _categories.keys.elementAt(index);
                final categoryData = _categories[categoryName]!;
                final isSelected = _selectedCategory == categoryName;
                
                return Card(
                  elevation: isSelected ? 6 : 2,
                  color: isSelected ? categoryData['color'].withOpacity(0.1) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? categoryData['color'] : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedCategory = categoryName),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            categoryData['icon'],
                            color: categoryData['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? categoryData['color'] : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_selectedCategory.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _categories[_selectedCategory]!['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examples:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _categories[_selectedCategory]!['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categories[_selectedCategory]!['examples'].join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: _categories[_selectedCategory]!['color'].withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Colors.pink, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Colors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                const Spacer(),
                if (_selectedColors.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedColors.length} selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.entries.map((entry) {
                final colorName = entry.key;
                final color = entry.value;
                final isSelected = _selectedColors.contains(colorName);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedColors.remove(colorName);
                      } else {
                        _selectedColors.add(colorName);
                      }
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.pink : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          right: 2,
                          child: Text(
                            colorName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: color.computeLuminance() > 0.5 
                                  ? Colors.black87 
                                  : Colors.white,
                            ),
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

  Widget _buildOccasionSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Occasions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const Spacer(),
                if (_selectedOccasions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedOccasions.length} selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _occasions.entries.map((entry) {
                final occasionName = entry.key;
                final occasionData = entry.value;
                final isSelected = _selectedOccasions.contains(occasionName);
                
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        occasionData['icon'],
                        size: 16,
                        color: isSelected ? Colors.white : occasionData['color'],
                      ),
                      const SizedBox(width: 6),
                      Text(occasionName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedOccasions.add(occasionName);
                      } else {
                        _selectedOccasions.remove(occasionName);
                      }
                    });
                  },
                  selectedColor: occasionData['color'],
                  backgroundColor: occasionData['color'].withOpacity(0.1),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : occasionData['color'],
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: isSelected ? 4 : 1,
                  pressElevation: 6,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: _isUploading ? 'Saving to Wardrobe...' : 'Save to Wardrobe',
      onPressed: _canSave() ? _saveClothingItem : () {},
      isLoading: _isUploading,
      backgroundColor: _canSave() ? Colors.pink : Colors.grey,
    );
  }

  bool _canSave() {
    return _imageBytes != null && 
           _selectedColors.isNotEmpty && 
           _selectedOccasions.isNotEmpty &&
           !_isUploading;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _saveClothingItem() async {
    if (!_canSave()) return;

    setState(() => _isUploading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user!.uid;

      // Upload image to Firebase Storage
      final imageUrl = await _databaseService.uploadClothingImage(
        _imageBytes!,
        userId,
      );

      // Create clothing item
      final clothingItem = ClothingItem(
        id: _generateId(),
        userId: userId,
        imageUrl: imageUrl,
        category: _selectedCategory,
        colors: _selectedColors,
        style: 'casual', // Default for now
        occasions: _selectedOccasions,
        seasons: ['spring', 'summer', 'fall', 'winter'], // Default for now
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _databaseService.addClothingItem(clothingItem);

      // Show success and go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Item added to wardrobe! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to save clothing item: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}