import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../models/clothing_item_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Add clothing item to Firestore
  Future<void> addClothingItem(ClothingItem item) async {
    try {
      await _firestore
          .collection('clothing_items')
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      print('Error adding clothing item: $e');
      throw e;
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadClothingImage(Uint8List imageBytes, String userId) async {
    try {
      String fileName = '${_uuid.v4()}.jpg';
      String filePath = 'wardrobe/$userId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(imageBytes);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  // Get user's clothing items
  Stream<List<ClothingItem>> getUserClothingItems(String userId) {
    return _firestore
        .collection('clothing_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Get the items
      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();
      
      // Sort on client side (newest first)
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // Delete clothing item
  Future<void> deleteClothingItem(String itemId) async {
    try {
      await _firestore
          .collection('clothing_items')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting clothing item: $e');
      throw e;
    }
  }

  // Update user profile - Enhanced to support new profile fields
  Future<void> updateUserProfile(Map<String, dynamic> userData, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(userData);
      print('✅ User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Get user profile - Enhanced to support new profile fields
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('✅ User profile retrieved: ${data['name']} - Profile Complete: ${data['isProfileComplete'] ?? false}');
        return data;
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  // Create initial user profile (called during registration)
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData['uid'])
          .set(userData);
      print('✅ User profile created successfully');
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  // Get clothing items by category
  Stream<List<ClothingItem>> getClothingItemsByCategory(String userId, String category) {
    return _firestore
        .collection('clothing_items')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();
      
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // Get clothing items by occasion
  Stream<List<ClothingItem>> getClothingItemsByOccasion(String userId, String occasion) {
    return _firestore
        .collection('clothing_items')
        .where('userId', isEqualTo: userId)
        .where('occasions', arrayContains: occasion)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();
      
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // Get clothing items by color
  Stream<List<ClothingItem>> getClothingItemsByColor(String userId, String color) {
    return _firestore
        .collection('clothing_items')
        .where('userId', isEqualTo: userId)
        .where('colors', arrayContains: color)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();
      
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // Web-compatible image URL method (simplified)
  String getSimpleImageUrl(String originalUrl) {
    try {
      // Extract just the essential parts and create a simple URL
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 5) {
        final imagePath = Uri.decodeComponent(pathSegments[4]);
        final bucket = 'fashion-ai-agent.firebasestorage.app';
        
        // Create the simplest possible URL format
        final simpleUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(imagePath)}?alt=media';
        
        print('🔧 Simple URL: ${simpleUrl.substring(0, 80)}...');
        return simpleUrl;
      }
    } catch (e) {
      print('❌ URL parsing error: $e');
    }
    
    // Ultimate fallback: use original but simplified
    final baseUrl = originalUrl.split('?')[0];
    return '$baseUrl?alt=media';
  }

  // Statistics methods for dashboard (future enhancement)
  Future<Map<String, int>> getUserWardrobeStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, int> stats = {
        'total': 0,
        'tops': 0,
        'bottoms': 0,
        'dresses': 0,
        'shoes': 0,
        'accessories': 0,
        'outerwear': 0,
      };

      for (var doc in snapshot.docs) {
        final item = ClothingItem.fromMap(doc.data());
        stats['total'] = stats['total']! + 1;
        
        switch (item.category.toLowerCase()) {
          case 'top':
            stats['tops'] = stats['tops']! + 1;
            break;
          case 'bottom':
            stats['bottoms'] = stats['bottoms']! + 1;
            break;
          case 'dress':
            stats['dresses'] = stats['dresses']! + 1;
            break;
          case 'shoes':
            stats['shoes'] = stats['shoes']! + 1;
            break;
          case 'accessories':
            stats['accessories'] = stats['accessories']! + 1;
            break;
          case 'outerwear':
            stats['outerwear'] = stats['outerwear']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting wardrobe stats: $e');
      return {
        'total': 0,
        'tops': 0,
        'bottoms': 0,
        'dresses': 0,
        'shoes': 0,
        'accessories': 0,
        'outerwear': 0,
      };
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(Uint8List imageBytes, String userId) async {
    try {
      String fileName = 'profile_${_uuid.v4()}.jpg';
      String filePath = 'profiles/$userId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(imageBytes);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      
      print('✅ Profile image uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw e;
    }
  }

  // Get outfit recommendations (placeholder for future AI integration)
  Future<List<Map<String, dynamic>>> getOutfitRecommendations(
    String userId, 
    String occasion, 
    String season
  ) async {
    try {
      // This is a placeholder for future AI recommendations
      // For now, return simple combinations
      final snapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .where('occasions', arrayContains: occasion)
          .get();

      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();

      // Simple combination logic (to be replaced with AI)
      List<Map<String, dynamic>> recommendations = [];
      
      final tops = items.where((item) => item.category == 'Top').toList();
      final bottoms = items.where((item) => item.category == 'Bottom').toList();
      final shoes = items.where((item) => item.category == 'Shoes').toList();
      
      for (int i = 0; i < 3 && i < tops.length; i++) {
        if (i < bottoms.length && i < shoes.length) {
          recommendations.add({
            'id': '${tops[i].id}_${bottoms[i].id}_${shoes[i].id}',
            'top': tops[i].toMap(),
            'bottom': bottoms[i].toMap(),
            'shoes': shoes[i].toMap(),
            'score': 0.8 - (i * 0.1), // Simple scoring
            'occasion': occasion,
          });
        }
      }

      return recommendations;
    } catch (e) {
      print('Error getting outfit recommendations: $e');
      return [];
    }
  }

  // Save outfit combination
  Future<void> saveOutfitCombination(Map<String, dynamic> outfit) async {
    try {
      await _firestore
          .collection('saved_outfits')
          .doc(outfit['id'])
          .set({
        ...outfit,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Outfit combination saved successfully');
    } catch (e) {
      print('Error saving outfit combination: $e');
      throw e;
    }
  }

  // Get saved outfits
  Stream<List<Map<String, dynamic>>> getSavedOutfits(String userId) {
    return _firestore
        .collection('saved_outfits')
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  // Update clothing item
  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      await _firestore
          .collection('clothing_items')
          .doc(item.id)
          .update(item.toMap());
      print('✅ Clothing item updated successfully');
    } catch (e) {
      print('Error updating clothing item: $e');
      throw e;
    }
  }

  // Get clothing item by ID
  Future<ClothingItem?> getClothingItemById(String itemId) async {
    try {
      final doc = await _firestore
          .collection('clothing_items')
          .doc(itemId)
          .get();
      
      if (doc.exists) {
        return ClothingItem.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting clothing item: $e');
    }
    return null;
  }

  // Search clothing items
  Future<List<ClothingItem>> searchClothingItems(
    String userId, 
    String query
  ) async {
    try {
      final snapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .get();

      final items = snapshot.docs.map((doc) {
        return ClothingItem.fromMap(doc.data());
      }).toList();

      // Simple text search (can be enhanced with better search)
      final filteredItems = items.where((item) {
        final searchText = query.toLowerCase();
        return item.category.toLowerCase().contains(searchText) ||
               item.colors.any((color) => color.toLowerCase().contains(searchText)) ||
               item.occasions.any((occasion) => occasion.toLowerCase().contains(searchText)) ||
               (item.brand?.toLowerCase().contains(searchText) ?? false);
      }).toList();

      return filteredItems;
    } catch (e) {
      print('Error searching clothing items: $e');
      return [];
    }
  }

  // Get popular colors for user
  Future<List<String>> getUserPopularColors(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, int> colorCount = {};
      
      for (var doc in snapshot.docs) {
        final item = ClothingItem.fromMap(doc.data());
        for (var color in item.colors) {
          colorCount[color] = (colorCount[color] ?? 0) + 1;
        }
      }

      // Sort by frequency and return top colors
      final sortedColors = colorCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedColors.take(5).map((e) => e.key).toList();
    } catch (e) {
      print('Error getting popular colors: $e');
      return [];
    }
  }

  // Get popular occasions for user
  Future<List<String>> getUserPopularOccasions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, int> occasionCount = {};
      
      for (var doc in snapshot.docs) {
        final item = ClothingItem.fromMap(doc.data());
        for (var occasion in item.occasions) {
          occasionCount[occasion] = (occasionCount[occasion] ?? 0) + 1;
        }
      }

      // Sort by frequency and return top occasions
      final sortedOccasions = occasionCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedOccasions.take(5).map((e) => e.key).toList();
    } catch (e) {
      print('Error getting popular occasions: $e');
      return [];
    }
  }
}