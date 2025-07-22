import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clothing_item_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../avatar/avatar_preview_widget.dart';

class FashionTabScreen extends StatefulWidget {
  const FashionTabScreen({Key? key}) : super(key: key);

  @override
  State<FashionTabScreen> createState() => _FashionTabScreenState();
}

class _FashionTabScreenState extends State<FashionTabScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;
  
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedOutfit;
  ClothingItem? _selectedJacket;
  
  UserModel? _currentUser;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.user != null) {
      final userData = await _databaseService.getUserProfile(authService.user!.uid);
      if (userData != null) {
        setState(() {
          _currentUser = UserModel.fromMap(userData);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Studio'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Avatar'),
            Tab(icon: Icon(Icons.checkroom), text: 'Wardrobe'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.pink.shade50],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAvatarTab(),
            _buildWardrobeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarTab() {
    if (_currentUser?.avatarData == null) {
      return const Center(
        child: Text(
          'Please complete avatar setup first',
          style: TextStyle(fontSize: 18, color: Colors.purple),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar Display with Current Outfit
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Your Avatar ✨',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AvatarPreviewWidget(
                    avatarData: _currentUser!.avatarData!,
                    clothingItem: _getCurrentOutfitItem(),
                    size: 250,
                  ),
                  const SizedBox(height: 20),
                  _buildCurrentOutfitSummary(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Try-On Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWardrobeTab() {
    final authService = Provider.of<AuthService>(context);
    
    return Column(
      children: [
        // Category Filter
        _buildCategoryFilter(),
        
        // Clothing Grid
        Expanded(
          child: StreamBuilder<List<ClothingItem>>(
            stream: _databaseService.getUserClothingItems(authService.user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allItems = snapshot.data ?? [];
              final filteredItems = _filterItems(allItems);

              if (filteredItems.isEmpty) {
                return _buildEmptyWardrobeState();
              }

              return _buildClothingGrid(filteredItems);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...ClothingCategories.allCategories];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.purple,
              backgroundColor: Colors.purple.shade50,
            ),
          );
        },
      ),
    );
  }

  Widget _buildClothingGrid(List<ClothingItem> items) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildClothingCard(item);
        },
      ),
    );
  }

  Widget _buildClothingCard(ClothingItem item) {
    final isSelected = _isItemSelected(item);
    
    return GestureDetector(
      onTap: () => _onClothingItemTap(item),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isSelected 
              ? BorderSide(color: Colors.purple, width: 3)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade100, Colors.grey.shade200],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.checkroom, size: 40, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayCategory,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.colors.join(', '),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.purple.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.occasions.join(', '),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple.shade400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Text(
                            'WEARING',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOutfitSummary() {
    final outfit = _getCurrentOutfit();
    
    if (outfit.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Tap clothing items to try them on! 👗',
          style: TextStyle(
            color: Colors.purple.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Outfit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...outfit.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.category}: ${item.displayCategory}',
                  style: TextStyle(color: Colors.purple.shade600),
                ),
                GestureDetector(
                  onTap: () => _removeItem(item),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.purple.shade400,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearOutfit,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Outfit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveOutfit,
                    icon: const Icon(Icons.favorite),
                    label: const Text('Save Outfit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
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

  Widget _buildEmptyWardrobeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 80,
            color: Colors.purple.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'No clothes in this category',
            style: TextStyle(
              fontSize: 18,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Navigate to add clothing screen
              Navigator.pushNamed(context, '/add-clothing');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Clothes'),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<ClothingItem> _filterItems(List<ClothingItem> items) {
    if (_selectedCategory == 'All') return items;
    return items.where((item) => item.category == _selectedCategory).toList();
  }

  ClothingItem? _getCurrentOutfitItem() {
    // Return the most prominent item for avatar display
    return _selectedOutfit ?? _selectedTop ?? _selectedBottom;
  }

  List<ClothingItem> _getCurrentOutfit() {
    final outfit = <ClothingItem>[];
    if (_selectedTop != null) outfit.add(_selectedTop!);
    if (_selectedBottom != null) outfit.add(_selectedBottom!);
    if (_selectedShoes != null) outfit.add(_selectedShoes!);
    if (_selectedOutfit != null) outfit.add(_selectedOutfit!);
    if (_selectedJacket != null) outfit.add(_selectedJacket!);
    return outfit;
  }

  bool _isItemSelected(ClothingItem item) {
    return item == _selectedTop ||
           item == _selectedBottom ||
           item == _selectedShoes ||
           item == _selectedOutfit ||
           item == _selectedJacket;
  }

  void _onClothingItemTap(ClothingItem item) {
    setState(() {
      switch (item.category) {
        case 'Tops':
          _selectedTop = _selectedTop == item ? null : item;
          if (_selectedTop != null) _selectedOutfit = null; // Clear outfit if selecting separates
          break;
        case 'Bottoms':
          _selectedBottom = _selectedBottom == item ? null : item;
          if (_selectedBottom != null) _selectedOutfit = null;
          break;
        case 'Shoes':
          _selectedShoes = _selectedShoes == item ? null : item;
          break;
        case 'Outfits':
          _selectedOutfit = _selectedOutfit == item ? null : item;
          if (_selectedOutfit != null) {
            _selectedTop = null; // Clear separates if selecting outfit
            _selectedBottom = null;
          }
          break;
        case 'Jackets':
          _selectedJacket = _selectedJacket == item ? null : item;
          break;
      }
    });

    // Switch to avatar tab to see the change
    _tabController.animateTo(0);
  }

  void _removeItem(ClothingItem item) {
    setState(() {
      if (item == _selectedTop) _selectedTop = null;
      if (item == _selectedBottom) _selectedBottom = null;
      if (item == _selectedShoes) _selectedShoes = null;
      if (item == _selectedOutfit) _selectedOutfit = null;
      if (item == _selectedJacket) _selectedJacket = null;
    });
  }

  void _clearOutfit() {
    setState(() {
      _selectedTop = null;
      _selectedBottom = null;
      _selectedShoes = null;
      _selectedOutfit = null;
      _selectedJacket = null;
    });
  }

  Future<void> _saveOutfit() async {
    final outfit = _getCurrentOutfit();
    if (outfit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No outfit to save!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Implement outfit saving functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Outfit saved! (${outfit.length} items)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
