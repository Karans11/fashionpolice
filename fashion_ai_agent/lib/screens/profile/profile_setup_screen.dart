import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel user;
  
  const ProfileSetupScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  String? _selectedGender;
  String? _selectedBodyType;
  String? _selectedSkinTone;
  String? _selectedHairColor;
  String? _selectedEyeColor;

  final List<String> _genderOptions = ['Female', 'Male', 'Other'];
  
  final Map<String, String> _bodyTypes = {
    'Inverted Triangle': '🔻',
    'Lean Column': '📏',
    'Rectangle': '⬜',
    'Apple': '🍎',
    'Pear': '🍐',
    'Neat Hour Glass': '⏳',
    'Full Hour Glass': '⌛',
  };

  final Map<String, Color> _skinTones = {
    'Cool - Fair': Color(0xFFFFDBBF),
    'Cool - Light': Color(0xFFE8C4A0),
    'Cool - Medium': Color(0xFFD4A574),
    'Warm - Fair': Color(0xFFF5DEB3),
    'Warm - Light': Color(0xFFDEB887),
    'Warm - Medium': Color(0xFFCD853F),
    'Neutral - Fair': Color(0xFFF0E68C),
    'Neutral - Light': Color(0xFFDAA520),
    'Neutral - Medium': Color(0xFFB8860B),
  };

  final Map<String, Color> _hairColors = {
    'Blonde': Color(0xFFFAF0BE),
    'Light Brown': Color(0xFFD2B48C),
    'Dark Brown': Color(0xFF8B4513),
    'Black': Color(0xFF2F1B14),
    'Auburn': Color(0xFFA52A2A),
    'Red': Color(0xFFFF4500),
    'Gray': Color(0xFF808080),
    'White': Color(0xFFF5F5F5),
  };

  final Map<String, Color> _eyeColors = {
    'Brown': Color(0xFF8B4513),
    'Blue': Color(0xFF1E90FF),
    'Green': Color(0xFF228B22),
    'Hazel': Color(0xFF8FBC8F),
    'Gray': Color(0xFF708090),
    'Amber': Color(0xFFFFBF00),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGenderStep(),
                    _buildBodyTypeStep(),
                    _buildSkinToneStep(),
                    _buildHairColorStep(),
                    _buildEyeColorStep(),
                    _buildCompletionStep(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 6,
            backgroundColor: Colors.purple.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text(
            'Step ${_currentStep + 1} of 6',
            style: TextStyle(
              color: Colors.purple.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return _buildStepContainer(
      title: 'Select Your Gender',
      subtitle: 'This helps us provide better recommendations',
      child: Column(
        children: _genderOptions.map((gender) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: _selectedGender == gender ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: _selectedGender == gender ? Colors.pink : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedGender == gender ? Colors.pink.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    gender == 'Female' ? Icons.female : 
                    gender == 'Male' ? Icons.male : Icons.person,
                    color: _selectedGender == gender ? Colors.pink : Colors.grey.shade600,
                  ),
                ),
                title: Text(
                  gender,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _selectedGender == gender ? Colors.pink : Colors.black,
                  ),
                ),
                onTap: () => setState(() => _selectedGender = gender),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBodyTypeStep() {
    return _buildStepContainer(
      title: 'Choose Your Body Type',
      subtitle: 'Select the shape that best matches your body',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _bodyTypes.length,
        itemBuilder: (context, index) {
          final bodyType = _bodyTypes.keys.elementAt(index);
          final emoji = _bodyTypes[bodyType]!;
          final isSelected = _selectedBodyType == bodyType;
          
          return Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? Colors.pink : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => setState(() => _selectedBodyType = bodyType),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bodyType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.pink : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkinToneStep() {
    return _buildStepContainer(
      title: 'Select Your Skin Tone',
      subtitle: 'Choose the tone that best matches your complexion',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _skinTones.length,
        itemBuilder: (context, index) {
          final skinTone = _skinTones.keys.elementAt(index);
          final color = _skinTones[skinTone]!;
          final isSelected = _selectedSkinTone == skinTone;
          
          return Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? Colors.pink : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => setState(() => _selectedSkinTone = skinTone),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    skinTone.split(' - ').last,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.pink : Colors.black,
                    ),
                  ),
                  Text(
                    skinTone.split(' - ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.pink.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHairColorStep() {
    return _buildStepContainer(
      title: 'Choose Your Hair Color',
      subtitle: 'Select your current hair color',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _hairColors.length,
        itemBuilder: (context, index) {
          final hairColor = _hairColors.keys.elementAt(index);
          final color = _hairColors[hairColor]!;
          final isSelected = _selectedHairColor == hairColor;
          
          return Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? Colors.pink : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => setState(() => _selectedHairColor = hairColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hairColor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.pink : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEyeColorStep() {
    return _buildStepContainer(
      title: 'Select Your Eye Color',
      subtitle: 'Choose your natural eye color',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _eyeColors.length,
        itemBuilder: (context, index) {
          final eyeColor = _eyeColors.keys.elementAt(index);
          final color = _eyeColors[eyeColor]!;
          final isSelected = _selectedEyeColor == eyeColor;
          
          return Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? Colors.pink : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => setState(() => _selectedEyeColor = eyeColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eyeColor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.pink : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionStep() {
    return _buildStepContainer(
      title: 'Profile Complete! 🎉',
      subtitle: 'You\'re all set to start your fashion journey',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.pink,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Perfect!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your profile is now complete. Our AI can provide personalized fashion recommendations based on your preferences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.pink.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildProfileSummary(),
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Profile Summary:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Gender', _selectedGender ?? ''),
            _buildSummaryRow('Body Type', _selectedBodyType ?? ''),
            _buildSummaryRow('Skin Tone', _selectedSkinTone ?? ''),
            _buildSummaryRow('Hair Color', _selectedHairColor ?? ''),
            _buildSummaryRow('Eye Color', _selectedEyeColor ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple.shade500,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep == 5 ? 'Complete Profile' : 'Next',
              onPressed: _canProceed() ? (_currentStep == 5 ? _completeProfile : _goToNextStep) : () {},
              isLoading: _isLoading,
              backgroundColor: _canProceed() ? Colors.pink : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return _selectedGender != null;
      case 1: return _selectedBodyType != null;
      case 2: return _selectedSkinTone != null;
      case 3: return _selectedHairColor != null;
      case 4: return _selectedEyeColor != null;
      case 5: return true;
      default: return false;
    }
  }

  void _goToNextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        gender: _selectedGender,
        bodyType: _selectedBodyType,
        skinTone: _selectedSkinTone,
        hairColor: _selectedHairColor,
        eyeColor: _selectedEyeColor,
        isProfileComplete: true,
      );

      await _databaseService.updateUserProfile(updatedUser.toMap(), widget.user.uid);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showError('Failed to save profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}