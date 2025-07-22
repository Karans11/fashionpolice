import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../avatar/avatar_preview_widget.dart';

class AvatarSetupScreen extends StatefulWidget {
  const AvatarSetupScreen({Key? key}) : super(key: key);

  @override
  State<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends State<AvatarSetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Avatar customization data
  String _selectedBodyType = 'medium';
  String _selectedSkinTone = 'medium';
  String _selectedFaceShape = 'oval';
  String _selectedEyeShape = 'almond';
  String _selectedEyeColor = 'brown';
  String _selectedEyebrowShape = 'arched';
  String _selectedNoseShape = 'straight';
  String _selectedMouthShape = 'medium';
  String _selectedLipColor = 'natural';
  bool _hasEyelashes = true;
  String _selectedHairStyle = 'straight';
  String _selectedHairColor = 'brown';
  String _selectedHairLength = 'medium';
  String _selectedHairTexture = 'smooth';

  final List<Map<String, dynamic>> _bodyTypes = [
    {'value': 'slim', 'label': 'Slim', 'icon': Icons.accessibility_new, 'description': 'Lean and slender build'},
    {'value': 'medium', 'label': 'Medium', 'icon': Icons.accessibility, 'description': 'Balanced proportions'},
    {'value': 'curvy', 'label': 'Curvy', 'icon': Icons.pregnant_woman, 'description': 'Fuller figure with curves'},
    {'value': 'athletic', 'label': 'Athletic', 'icon': Icons.fitness_center, 'description': 'Toned and muscular'},
  ];

  final List<Map<String, dynamic>> _skinTones = [
    {'value': 'fair', 'label': 'Fair', 'color': Color(0xFFFDBCB4)},
    {'value': 'light', 'label': 'Light', 'color': Color(0xFFEDB98A)},
    {'value': 'medium', 'label': 'Medium', 'color': Color(0xFFD08B5B)},
    {'value': 'tan', 'label': 'Tan', 'color': Color(0xFFAE7242)},
    {'value': 'dark', 'label': 'Dark', 'color': Color(0xFF8D5524)},
  ];

  final List<Map<String, dynamic>> _faceShapes = [
    {'value': 'oval', 'label': 'Oval', 'icon': Icons.face},
    {'value': 'round', 'label': 'Round', 'icon': Icons.face_2},
    {'value': 'square', 'label': 'Square', 'icon': Icons.face_3},
    {'value': 'heart', 'label': 'Heart', 'icon': Icons.face_4},
    {'value': 'diamond', 'label': 'Diamond', 'icon': Icons.face_5},
  ];

  final List<Map<String, dynamic>> _eyeShapes = [
    {'value': 'almond', 'label': 'Almond'},
    {'value': 'round', 'label': 'Round'},
    {'value': 'hooded', 'label': 'Hooded'},
    {'value': 'upturned', 'label': 'Upturned'},
    {'value': 'downturned', 'label': 'Downturned'},
  ];

  final List<Map<String, dynamic>> _eyeColors = [
    {'value': 'brown', 'label': 'Brown', 'color': Color(0xFF8B4513)},
    {'value': 'blue', 'label': 'Blue', 'color': Color(0xFF4169E1)},
    {'value': 'green', 'label': 'Green', 'color': Color(0xFF228B22)},
    {'value': 'hazel', 'label': 'Hazel', 'color': Color(0xFF8E7618)},
    {'value': 'gray', 'label': 'Gray', 'color': Color(0xFF708090)},
    {'value': 'amber', 'label': 'Amber', 'color': Color(0xFFFFBF00)},
  ];

  final List<String> _eyebrowShapes = ['arched', 'straight', 'rounded', 'angular'];
  final List<String> _noseShapes = ['straight', 'button', 'roman', 'aquiline'];
  final List<String> _mouthShapes = ['small', 'medium', 'full', 'wide'];
  
  final List<Map<String, dynamic>> _lipColors = [
    {'value': 'natural', 'label': 'Natural', 'color': Color(0xFFFFB6C1)},
    {'value': 'pink', 'label': 'Pink', 'color': Color(0xFFFFB6C1)},
    {'value': 'red', 'label': 'Red', 'color': Color(0xFFDC143C)},
    {'value': 'coral', 'label': 'Coral', 'color': Color(0xFFFF7F50)},
    {'value': 'berry', 'label': 'Berry', 'color': Color(0xFF8B008B)},
  ];

  final List<Map<String, dynamic>> _hairStyles = [
    {'value': 'straight', 'label': 'Straight', 'icon': Icons.straighten},
    {'value': 'wavy', 'label': 'Wavy', 'icon': Icons.waves},
    {'value': 'curly', 'label': 'Curly', 'icon': Icons.rotate_right},
    {'value': 'braided', 'label': 'Braided', 'icon': Icons.grid_view},
    {'value': 'updo', 'label': 'Updo', 'icon': Icons.keyboard_arrow_up},
  ];

  final List<Map<String, dynamic>> _hairColors = [
    {'value': 'black', 'label': 'Black', 'color': Color(0xFF000000)},
    {'value': 'brown', 'label': 'Brown', 'color': Color(0xFF8B4513)},
    {'value': 'blonde', 'label': 'Blonde', 'color': Color(0xFFFAD5A5)},
    {'value': 'red', 'label': 'Red', 'color': Color(0xFFDC143C)},
    {'value': 'auburn', 'label': 'Auburn', 'color': Color(0xFFA52A2A)},
    {'value': 'gray', 'label': 'Gray', 'color': Color(0xFF808080)},
  ];

  final List<Map<String, dynamic>> _hairLengths = [
    {'value': 'short', 'label': 'Short', 'icon': Icons.content_cut},
    {'value': 'medium', 'label': 'Medium', 'icon': Icons.face_retouching_natural},
    {'value': 'long', 'label': 'Long', 'icon': Icons.face_6},
    {'value': 'extra-long', 'label': 'Extra Long', 'icon': Icons.height},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                    _animationController.reset();
                    _animationController.forward();
                  },
                  children: [
                    _buildBodyCustomization(),
                    _buildFaceCustomization(),
                    _buildHairCustomization(),
                    _buildPreviewAndFinish(),
                  ],
                ),
              ),
              _buildEnhancedBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    final titles = [
      'Choose Your Body Type',
      'Customize Your Face',
      'Style Your Hair',
      'Your 3D Avatar'
    ];

    final subtitles = [
      'Define your body shape and skin tone',
      'Create your unique facial features',
      'Pick your perfect hairstyle',
      'Preview and save your creation'
    ];

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.pink.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your 3D Avatar ✨',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            Text(
                              titles[_currentPage],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitles[_currentPage],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.purple.shade100,
                    ),
                    child: Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: index < 3 ? 2 : 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: index <= _currentPage
                                  ? LinearGradient(
                                      colors: [Colors.purple.shade400, Colors.pink.shade400],
                                    )
                                  : null,
                              color: index <= _currentPage ? null : Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildEnhanced3DAvatarPreview(),
                const SizedBox(height: 30),
                _buildEnhancedBodyTypeSection(),
                const SizedBox(height: 25),
                _buildEnhancedSkinToneSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaceCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildEnhanced3DAvatarPreview(),
                const SizedBox(height: 30),
                _buildEnhancedFaceShapeSection(),
                const SizedBox(height: 20),
                _buildEnhancedEyeSection(),
                const SizedBox(height: 20),
                _buildEnhancedLipSection(),
                const SizedBox(height: 20),
                _buildEyelashToggle(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHairCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildEnhanced3DAvatarPreview(),
                const SizedBox(height: 30),
                _buildEnhancedHairStyleSection(),
                const SizedBox(height: 20),
                _buildEnhancedHairColorSection(),
                const SizedBox(height: 20),
                _buildEnhancedHairLengthSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewAndFinish() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.pink.shade100],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Beautiful 3D Avatar! 🎉',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildEnhanced3DAvatarPreview(size: 300),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildAvatarSummaryCard(),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Complete 3D Avatar Setup',
                  onPressed: _saveAvatar,
                  isLoading: _isLoading,
                  backgroundColor: Colors.purple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhanced3DAvatarPreview({double size = 250}) {
    return Hero(
      tag: 'avatar-preview',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AvatarPreviewWidget(
          avatarData: AvatarData(
            bodyType: _selectedBodyType,
            skinTone: _selectedSkinTone,
            faceData: FaceData(
              faceShape: _selectedFaceShape,
              eyeShape: _selectedEyeShape,
              eyeColor: _selectedEyeColor,
              eyebrowShape: _selectedEyebrowShape,
              noseShape: _selectedNoseShape,
              mouthShape: _selectedMouthShape,
              lipColor: _selectedLipColor,
              hasEyelashes: _hasEyelashes,
            ),
            hairData: HairData(
              hairStyle: _selectedHairStyle,
              hairColor: _selectedHairColor,
              hairLength: _selectedHairLength,
              hairTexture: _selectedHairTexture,
            ),
          ),
          size: size,
        ),
      ),
    );
  }

  Widget _buildEnhancedBodyTypeSection() {
    return _buildEnhancedSection(
      title: 'Body Type',
      icon: Icons.accessibility_new,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _bodyTypes.length,
        itemBuilder: (context, index) {
          final bodyType = _bodyTypes[index];
          final isSelected = _selectedBodyType == bodyType['value'];
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              elevation: isSelected ? 8 : 2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _selectedBodyType = bodyType['value']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [Colors.purple.shade300, Colors.pink.shade300],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.purple.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        bodyType['icon'],
                        size: 36,
                        color: isSelected ? Colors.white : Colors.purple.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bodyType['label'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bodyType['description'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.purple.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSkinToneSection() {
    return _buildEnhancedSection(
      title: 'Skin Tone',
      icon: Icons.palette,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _skinTones.map((tone) {
          final isSelected = _selectedSkinTone == tone['value'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSkinTone = tone['value']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tone['color'],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.purple.shade200,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedFaceShapeSection() {
    return _buildEnhancedSection(
      title: 'Face Shape',
      icon: Icons.face,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _faceShapes.map((shape) {
          final isSelected = _selectedFaceShape == shape['value'];
          return _buildSelectableChip(
            label: shape['label'],
            icon: shape['icon'],
            isSelected: isSelected,
            onTap: () => setState(() => _selectedFaceShape = shape['value']),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedEyeSection() {
    return _buildEnhancedSection(
      title: 'Eyes',
      icon: Icons.visibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eye Shape',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _eyeShapes.map((shape) {
              final isSelected = _selectedEyeShape == shape['value'];
              return _buildSelectableChip(
                label: shape['label'],
                isSelected: isSelected,
                onTap: () => setState(() => _selectedEyeShape = shape['value']),
                compact: true,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Eye Color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _eyeColors.map((eyeColor) {
              final isSelected = _selectedEyeColor == eyeColor['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedEyeColor = eyeColor['value']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: eyeColor['color'],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.purple.shade200,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLipSection() {
    return _buildEnhancedSection(
      title: 'Lips',
      icon: Icons.favorite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _lipColors.map((lipColor) {
          final isSelected = _selectedLipColor == lipColor['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedLipColor = lipColor['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lipColor['color'],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.purple.shade200,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEyelashToggle() {
    return _buildEnhancedSection(
      title: 'Eyelashes',
      icon: Icons.remove_red_eye,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add eyelashes to your avatar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade600,
            ),
          ),
          Switch(
            value: _hasEyelashes,
            onChanged: (value) => setState(() => _hasEyelashes = value),
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHairStyleSection() {
    return _buildEnhancedSection(
      title: 'Hair Style',
      icon: Icons.style,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _hairStyles.length,
        itemBuilder: (context, index) {
          final style = _hairStyles[index];
          final isSelected = _selectedHairStyle == style['value'];
          
          return _buildSelectableChip(
            label: style['label'],
            icon: style['icon'],
            isSelected: isSelected,
            onTap: () => setState(() => _selectedHairStyle = style['value']),
            compact: true,
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHairColorSection() {
    return _buildEnhancedSection(
      title: 'Hair Color',
      icon: Icons.color_lens,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _hairColors.map((hairColor) {
          final isSelected = _selectedHairColor == hairColor['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedHairColor = hairColor['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: hairColor['color'],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.purple.shade200,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedHairLengthSection() {
    return _buildEnhancedSection(
      title: 'Hair Length',
      icon: Icons.height,
      child: Row(
        children: _hairLengths.map((length) {
          final isSelected = _selectedHairLength == length['value'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildSelectableChip(
                label: length['label'],
                icon: length['icon'],
                isSelected: isSelected,
                onTap: () => setState(() => _selectedHairLength = length['value']),
                compact: true,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pink.shade400],
                )
              : null,
          color: isSelected ? null : Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.purple.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: compact ? 16 : 20,
                color: isSelected ? Colors.white : Colors.purple.shade600,
              ),
              SizedBox(width: compact ? 4 : 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.summarize, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Avatar Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Body Type', _selectedBodyType),
          _buildSummaryRow('Skin Tone', _selectedSkinTone),
          _buildSummaryRow('Face Shape', _selectedFaceShape),
          _buildSummaryRow('Eye Color', _selectedEyeColor),
          _buildSummaryRow('Hair Style', _selectedHairStyle),
          _buildSummaryRow('Hair Color', _selectedHairColor),
          _buildSummaryRow('Hair Length', _selectedHairLength),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple.shade600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: BorderSide(color: Colors.purple.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentPage > 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _currentPage < 3 ? _nextPage : null,
              icon: Icon(_currentPage < 3 ? Icons.arrow_forward : Icons.check),
              label: Text(_currentPage < 3 ? 'Next' : 'Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveAvatar() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.user;

      if (currentUser != null) {
        final avatarData = AvatarData(
          bodyType: _selectedBodyType,
          skinTone: _selectedSkinTone,
          faceData: FaceData(
            faceShape: _selectedFaceShape,
            eyeShape: _selectedEyeShape,
            eyeColor: _selectedEyeColor,
            eyebrowShape: _selectedEyebrowShape,
            noseShape: _selectedNoseShape,
            mouthShape: _selectedMouthShape,
            lipColor: _selectedLipColor,
            hasEyelashes: _hasEyelashes,
          ),
          hairData: HairData(
            hairStyle: _selectedHairStyle,
            hairColor: _selectedHairColor,
            hairLength: _selectedHairLength,
            hairTexture: _selectedHairTexture,
          ),
        );

        await _databaseService.updateUserProfile({
          'avatarData': avatarData.toMap(),
          'hasCompletedSetup': true,
        }, currentUser.uid);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}