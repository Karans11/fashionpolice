class ClothingItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String category; // Top, Bottom, Dress, Outerwear, Shoes, Accessories
  final List<String> colors;
  final String style; // casual, formal, party, athletic
  final List<String> occasions; // work, date, party, casual, formal, sports, home, beach
  final List<String> seasons; // spring, summer, fall, winter
  final DateTime createdAt;
  final String? brand;
  final String? size;
  final String? material;
  final String? notes;

  ClothingItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.category,
    required this.colors,
    required this.style,
    required this.occasions,
    required this.seasons,
    required this.createdAt,
    this.brand,
    this.size,
    this.material,
    this.notes,
  });

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      colors: List<String>.from(map['colors'] ?? []),
      style: map['style'] ?? '',
      occasions: List<String>.from(map['occasions'] ?? []),
      seasons: List<String>.from(map['seasons'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      brand: map['brand'],
      size: map['size'],
      material: map['material'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'category': category,
      'colors': colors,
      'style': style,
      'occasions': occasions,
      'seasons': seasons,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'brand': brand,
      'size': size,
      'material': material,
      'notes': notes,
    };
  }

  ClothingItem copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? category,
    List<String>? colors,
    String? style,
    List<String>? occasions,
    List<String>? seasons,
    DateTime? createdAt,
    String? brand,
    String? size,
    String? material,
    String? notes,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      style: style ?? this.style,
      occasions: occasions ?? this.occasions,
      seasons: seasons ?? this.seasons,
      createdAt: createdAt ?? this.createdAt,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      material: material ?? this.material,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods for UI
  String get primaryColor => colors.isNotEmpty ? colors.first : 'Unknown';
  
  String get occasionText => occasions.join(', ');
  
  String get colorText => colors.join(', ');
  
  bool get isOutfit => category.toLowerCase() == 'dress';
  
  bool get isAccessory => category.toLowerCase() == 'accessories';
  
  bool get isTop => category.toLowerCase() == 'top';
  
  bool get isBottom => category.toLowerCase() == 'bottom';
  
  bool get isShoes => category.toLowerCase() == 'shoes';
  
  bool get isOuterwear => category.toLowerCase() == 'outerwear';

  // Check if item is suitable for specific occasion
  bool isSuitableForOccasion(String occasion) {
    return occasions.any((o) => o.toLowerCase() == occasion.toLowerCase());
  }

  // Check if item matches specific color
  bool hasColor(String color) {
    return colors.any((c) => c.toLowerCase() == color.toLowerCase());
  }

  // Check if item is suitable for specific season
  bool isSuitableForSeason(String season) {
    return seasons.any((s) => s.toLowerCase() == season.toLowerCase());
  }

  // Get compatibility score with another item (for outfit recommendations)
  double getCompatibilityScore(ClothingItem other) {
    double score = 0.0;
    
    // Category compatibility
    if (canCombineWith(other)) {
      score += 0.3;
    }
    
    // Occasion compatibility
    final commonOccasions = occasions.where((o) => other.occasions.contains(o)).length;
    score += (commonOccasions / occasions.length) * 0.3;
    
    // Season compatibility
    final commonSeasons = seasons.where((s) => other.seasons.contains(s)).length;
    score += (commonSeasons / seasons.length) * 0.2;
    
    // Style compatibility
    if (style == other.style) {
      score += 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }

  // Check if this item can be combined with another item
  bool canCombineWith(ClothingItem other) {
    // Same category items usually don't combine (except accessories)
    if (category == other.category && !isAccessory) {
      return false;
    }
    
    // Dresses are standalone outfits
    if (isOutfit || other.isOutfit) {
      // Can only combine dresses with outerwear, shoes, or accessories
      return isOuterwear || isShoes || isAccessory || 
             other.isOuterwear || other.isShoes || other.isAccessory;
    }
    
    return true;
  }

  // Get suggested combinations for this item
  List<String> getSuggestedCombinations() {
    List<String> suggestions = [];
    
    switch (category.toLowerCase()) {
      case 'top':
        suggestions.addAll(['Bottom', 'Shoes', 'Accessories', 'Outerwear']);
        break;
      case 'bottom':
        suggestions.addAll(['Top', 'Shoes', 'Accessories', 'Outerwear']);
        break;
      case 'dress':
        suggestions.addAll(['Shoes', 'Accessories', 'Outerwear']);
        break;
      case 'shoes':
        suggestions.addAll(['Top', 'Bottom', 'Dress', 'Accessories']);
        break;
      case 'outerwear':
        suggestions.addAll(['Top', 'Bottom', 'Dress', 'Shoes', 'Accessories']);
        break;
      case 'accessories':
        suggestions.addAll(['Top', 'Bottom', 'Dress', 'Shoes', 'Outerwear']);
        break;
    }
    
    return suggestions;
  }

  @override
  String toString() {
    return 'ClothingItem(id: $id, category: $category, colors: $colors, occasions: $occasions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}