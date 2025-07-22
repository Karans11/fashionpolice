import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../wardrobe/wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, int>? _wardrobeStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadWardrobeStats();
  }

  Future<void> _loadWardrobeStats() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final stats = await _databaseService.getUserWardrobeStats(authService.user!.uid);
      setState(() {
        _wardrobeStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion AI Agent'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authService),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildWardrobeStatsCard(),
                const SizedBox(height: 24),
                _buildQuickActionsSection(),
                const SizedBox(height: 24),
                _buildFeaturesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade100, Colors.purple.shade100],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Fashion AI! 👗',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your personal fashion assistant is ready to help you look amazing!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeStatsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.pink, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Wardrobe Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingStats)
              const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              )
            else if (_wardrobeStats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Items',
                      _wardrobeStats!['total']!,
                      Icons.checkroom,
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Tops',
                      _wardrobeStats!['tops']!,
                      Icons.shopping_bag,
                      Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Bottoms',
                      _wardrobeStats!['bottoms']!,
                      Icons.fitness_center,
                      Colors.indigo,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Dresses',
                      _wardrobeStats!['dresses']!,
                      Icons.woman,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Unable to load wardrobe statistics',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'View Wardrobe',
                    Icons.checkroom,
                    Colors.pink,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WardrobeScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Add Clothing',
                    Icons.add_circle,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WardrobeScreen(),
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

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'My Wardrobe',
          'Upload and organize your clothes with smart categorization',
          Icons.checkroom,
          Colors.pink,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WardrobeScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'AI Recommendations',
          'Get personalized outfit suggestions based on your style',
          Icons.auto_awesome,
          Colors.purple,
          () => _showComingSoonDialog('AI Recommendations'),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Style Analytics',
          'Discover your fashion patterns and preferences',
          Icons.analytics,
          Colors.indigo,
          () => _showComingSoonDialog('Style Analytics'),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Outfit Planner',
          'Plan your outfits for the week ahead',
          Icons.calendar_today,
          Colors.teal,
          () => _showComingSoonDialog('Outfit Planner'),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.purple),
            const SizedBox(width: 12),
            const Text('Coming Soon!'),
          ],
        ),
        content: Text(
          '$feature is currently under development. Stay tuned for exciting updates!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}