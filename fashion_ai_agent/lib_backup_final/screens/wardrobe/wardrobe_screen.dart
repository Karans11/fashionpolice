import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clothing_item_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'add_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.checkroom,
      'color': Colors.purple,
    },
    {
      'name': 'Top',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
    },
    {
      'name': 'Bottom',
      'icon': Icons.fitness_center,
      'color': Colors.indigo,
    },
    {
      'name': 'Dress',
      'icon': Icons.woman,
      'color': Colors.teal,
    },
    {
      'name': 'Outerwear',
      'icon': Icons.ac_unit,
      'color': Colors.orange,
    },
    {
      'name': 'Shoes',
      'icon': Icons.directions_walk,
      'color': Colors.brown,
    },
    {
      'name': 'Accessories',
      'icon': Icons.watch,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((category) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category['icon'], size: 18),
                  const SizedBox(width: 6),
                  Text(category['name']),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddClothingScreen(),
            ),
          );
        },
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: StreamBuilder<List<ClothingItem>>(
          stream: _databaseService.getUserClothingItems(authService.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading wardrobe',
                      style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ],
                ),
              );
            }

            final allItems = snapshot.data ?? [];

            return TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final filteredItems = category['name'] == 'All'
                    ? allItems
                    : allItems.where((item) => item.category == category['name']).toList();

                if (filteredItems.isEmpty) {
                  return _buildEmptyState(category);
                }

                return _buildItemsGrid(filteredItems, category);
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, dynamic> category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                category['icon'],
                size: 64,
                color: category['color'],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              category['name'] == 'All' 
                  ? 'Your wardrobe is empty'
                  : 'No ${category['name'].toLowerCase()} items yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: category['color'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'] == 'All'
                  ? 'Start building your digital wardrobe!'
                  : 'Add your first ${category['name'].toLowerCase()} item!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddClothingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text('Add ${category['name'] == 'All' ? 'Clothing' : category['name']}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: category['color'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(List<ClothingItem> items, Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category['name'] != 'All') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: category['color'].withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category['icon'], size: 16, color: category['color']),
                  const SizedBox(width: 8),
                  Text(
                    '${items.length} ${category['name']} item${items.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: category['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
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
                return _buildClothingCard(item, category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingCard(ClothingItem item, Map<String, dynamic> category) {
    final categoryColor = _categories.firstWhere(
      (cat) => cat['name'] == item.category,
      orElse: () => _categories[0],
    )['color'] as Color;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                    top: Radius.circular(20),
                  ),
                  child: _buildItemImage(item.imageUrl),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(item.category),
                        size: 16,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (item.colors.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.palette, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.colors.join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (item.occasions.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.event, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.occasions.join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'top': return Icons.shopping_bag;
      case 'bottom': return Icons.fitness_center;
      case 'dress': return Icons.woman;
      case 'outerwear': return Icons.ac_unit;
      case 'shoes': return Icons.directions_walk;
      case 'accessories': return Icons.watch;
      default: return Icons.checkroom;
    }
  }

  Widget _buildItemImage(String originalUrl) {
    final cleanUrl = originalUrl.split('?')[0] + '?alt=media';
    
    return Image.network(
      cleanUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink.shade50, Colors.purple.shade50],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.pink,
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade100, Colors.grey.shade200],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.checkroom_outlined,
                      color: Colors.grey.shade600,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fashion Item',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Image loading...',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}