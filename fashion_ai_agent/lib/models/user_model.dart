class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String? gender;
  final String? bodyType;
  final String? skinTone;
  final String? hairColor;
  final String? eyeColor;
  final List<String> stylePreferences;
  final DateTime createdAt;
  final bool isProfileComplete;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.gender,
    this.bodyType,
    this.skinTone,
    this.hairColor,
    this.eyeColor,
    this.stylePreferences = const [],
    required this.createdAt,
    this.isProfileComplete = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      gender: map['gender'],
      bodyType: map['bodyType'],
      skinTone: map['skinTone'],
      hairColor: map['hairColor'],
      eyeColor: map['eyeColor'],
      stylePreferences: List<String>.from(map['stylePreferences'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'gender': gender,
      'bodyType': bodyType,
      'skinTone': skinTone,
      'hairColor': hairColor,
      'eyeColor': eyeColor,
      'stylePreferences': stylePreferences,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImageUrl,
    String? gender,
    String? bodyType,
    String? skinTone,
    String? hairColor,
    String? eyeColor,
    List<String>? stylePreferences,
    DateTime? createdAt,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      hairColor: hairColor ?? this.hairColor,
      eyeColor: eyeColor ?? this.eyeColor,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}