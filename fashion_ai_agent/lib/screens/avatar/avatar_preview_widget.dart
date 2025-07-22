import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as vector;
import '../../models/user_model.dart';

class Enhanced3DAvatarWidget extends StatefulWidget {
  final AvatarData avatarData;
  final ClothingItem? clothingItem;
  final double size;
  final bool enableInteraction;
  final bool enableAnimation;
  final VoidCallback? onTap;

  const Enhanced3DAvatarWidget({
    Key? key,
    required this.avatarData,
    this.clothingItem,
    this.size = 300,
    this.enableInteraction = true,
    this.enableAnimation = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<Enhanced3DAvatarWidget> createState() => _Enhanced3DAvatarWidgetState();
}

class _Enhanced3DAvatarWidgetState extends State<Enhanced3DAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late Animation<double> _rotationY;
  late Animation<double> _rotationX;
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;

  double _userRotationY = 0.0;
  double _userRotationX = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _rotationY = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _rotationX = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Breathing animation
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Blinking animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation) {
      _rotationController.repeat(reverse: true);
      _breathingController.repeat(reverse: true);
      _startBlinking();
    }
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _breathingController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enableInteraction) return;
    
    setState(() {
      _isDragging = true;
      _userRotationY += details.delta.dx * 0.01;
      _userRotationX -= details.delta.dy * 0.01;
      _userRotationX = _userRotationX.clamp(-0.5, 0.5);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.size,
        height: widget.size * 1.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              const Color(0xFFF8F9FA),
              const Color(0xFFE9ECEF),
              const Color(0xFFDEE2E6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _breathingController,
              _blinkController,
            ]),
            builder: (context, child) {
              final rotY = _isDragging ? _userRotationY : _rotationY.value + _userRotationY;
              final rotX = _isDragging ? _userRotationX : _rotationX.value + _userRotationX;
              
              return CustomPaint(
                size: Size(widget.size, widget.size * 1.3),
                painter: AppleStyleAvatarPainter(
                  avatarData: widget.avatarData,
                  clothingItem: widget.clothingItem,
                  rotationY: rotY,
                  rotationX: rotX,
                  breathingScale: _breathingAnimation.value,
                  eyeOpenness: _blinkAnimation.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppleStyleAvatarPainter extends CustomPainter {
  final AvatarData avatarData;
  final ClothingItem? clothingItem;
  final double rotationY;
  final double rotationX;
  final double breathingScale;
  final double eyeOpenness;

  AppleStyleAvatarPainter({
    required this.avatarData,
    this.clothingItem,
    required this.rotationY,
    required this.rotationX,
    required this.breathingScale,
    required this.eyeOpenness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Create advanced 3D transformation matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(rotationY)
      ..rotateX(rotationX)
      ..scale(breathingScale);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Apply 3D transformation
    canvas.transform(matrix.storage);
    
    // Draw enhanced 3D human model with Apple-like quality
    _drawAppleStyleAvatar(canvas, size);
    
    canvas.restore();
  }

  void _drawAppleStyleAvatar(Canvas canvas, Size size) {
    // Enhanced human proportions with more realistic measurements
    final humanHeight = size.height * 0.85;
    final headSize = humanHeight * 0.14; // More realistic head proportion
    final torsoHeight = humanHeight * 0.35;
    final legHeight = humanHeight * 0.51;
    
    // Dynamic body measurements based on avatar data
    final bodyWidth = _getEnhancedBodyWidth(size.width);
    final shoulderWidth = bodyWidth * _getShoulderMultiplier();
    final waistWidth = bodyWidth * _getWaistMultiplier();
    final hipWidth = bodyWidth * _getHipMultiplier();
    
    // Draw body parts with enhanced realism
    _drawEnhancedBackground(canvas, size);
    _drawEnhancedShadows(canvas, size, humanHeight);
    _drawEnhancedHead(canvas, size, headSize);
    _drawEnhancedNeck(canvas, size, headSize);
    _drawEnhancedTorso(canvas, size, torsoHeight, shoulderWidth, waistWidth);
    _drawEnhancedArms(canvas, size, shoulderWidth, torsoHeight);
    _drawEnhancedHips(canvas, size, torsoHeight, hipWidth);
    _drawEnhancedLegs(canvas, size, legHeight, hipWidth);
    _drawEnhancedFeet(canvas, size, legHeight);
    
    // Enhanced facial features with micro-expressions
    _drawEnhancedFacialFeatures(canvas, size, headSize);
    
    // Enhanced hair with realistic texture
    _drawEnhancedHair(canvas, size, headSize);
    
    // Enhanced clothing with fabric simulation
    if (clothingItem != null) {
      _drawEnhancedClothing(canvas, size, torsoHeight, bodyWidth);
    }
    
    // Add environmental lighting effects
    _drawEnvironmentalLighting(canvas, size);
  }

  void _drawEnhancedBackground(Canvas canvas, Size size) {
    // Create a more sophisticated background with depth
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 1.5,
        colors: [
          const Color(0xFFF8F9FA).withOpacity(0.9),
          const Color(0xFFE9ECEF).withOpacity(0.7),
          const Color(0xFFDEE2E6).withOpacity(0.5),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCenter(
        center: Offset(0, -size.height * 0.1),
        width: size.width * 2,
        height: size.height * 2,
      ));

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: size.width * 2,
        height: size.height * 2,
      ),
      backgroundPaint,
    );
  }

  void _drawEnhancedShadows(Canvas canvas, Size size, double humanHeight) {
    // Ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, size.height * 0.4),
        width: size.width * 0.6,
        height: size.width * 0.2,
      ),
      shadowPaint,
    );

    // Body shadow for depth
    final bodyShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.02, 0),
          width: size.width * 0.4,
          height: humanHeight,
        ),
        const Radius.circular(20),
      ),
      bodyShadowPaint,
    );
  }

  void _drawEnhancedHead(Canvas canvas, Size size, double headSize) {
    final skinColor = _getEnhancedSkinColor();
    final headCenter = Offset(0, -size.height * 0.32);
    
    // Create realistic head with subsurface scattering effect
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: [
          skinColor.withOpacity(0.95),
          skinColor,
          skinColor.withOpacity(0.85),
          skinColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCenter(
        center: headCenter,
        width: headSize * 2.5,
        height: headSize * 2.8,
      ));

    // Draw head shape with enhanced realism
    _drawRealisticHeadShape(canvas, headCenter, headSize, headPaint);
    
    // Add advanced head shading and highlights
    _addAdvancedHeadShading(canvas, headCenter, headSize);
    
    // Add skin texture
    _addSkinTexture(canvas, headCenter, headSize);
  }

  void _drawRealisticHeadShape(Canvas canvas, Offset center, double size, Paint paint) {
    switch (avatarData.faceData.faceShape) {
      case 'round':
        canvas.drawCircle(center, size * 0.65, paint);
        break;
      case 'square':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: size * 1.2,
              height: size * 1.3,
            ),
            const Radius.circular(12),
          ),
          paint,
        );
        break;
      case 'heart':
        _drawEnhancedHeartFace(canvas, center, size, paint);
        break;
      case 'diamond':
        _drawEnhancedDiamondFace(canvas, center, size, paint);
        break;
      case 'long':
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: size * 1.0,
            height: size * 1.5,
          ),
          paint,
        );
        break;
      default: // oval
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: size * 1.1,
            height: size * 1.35,
          ),
          paint,
        );
    }
  }

  void _drawEnhancedHeartFace(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.65);
    path.quadraticBezierTo(
      center.dx - size * 0.55, center.dy - size * 0.25,
      center.dx - size * 0.45, center.dy + size * 0.25,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.2, center.dy + size * 0.6,
      center.dx, center.dy + size * 0.75,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.2, center.dy + size * 0.6,
      center.dx + size * 0.45, center.dy + size * 0.25,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.55, center.dy - size * 0.25,
      center.dx, center.dy - size * 0.65,
    );
    canvas.drawPath(path, paint);
  }

  void _drawEnhancedDiamondFace(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.65);
    path.quadraticBezierTo(
      center.dx - size * 0.25, center.dy - size * 0.3,
      center.dx - size * 0.4, center.dy,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.25, center.dy + size * 0.3,
      center.dx, center.dy + size * 0.65,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.25, center.dy + size * 0.3,
      center.dx + size * 0.4, center.dy,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.25, center.dy - size * 0.3,
      center.dx, center.dy - size * 0.65,
    );
    canvas.drawPath(path, paint);
  }

  void _addAdvancedHeadShading(Canvas canvas, Offset center, double size) {
    // Cheekbone highlights
    final cheekbonePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Left cheekbone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.25, center.dy + size * 0.1),
        width: size * 0.3,
        height: size * 0.15,
      ),
      cheekbonePaint,
    );
    
    // Right cheekbone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.25, center.dy + size * 0.1),
        width: size * 0.3,
        height: size * 0.15,
      ),
      cheekbonePaint,
    );

    // Forehead highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size * 0.3),
        width: size * 0.4,
        height: size * 0.2,
      ),
      cheekbonePaint,
    );

    // Jaw shadow
    final jawShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.1, center.dy + size * 0.4),
        width: size * 0.8,
        height: size * 0.2,
      ),
      jawShadowPaint,
    );
  }

  void _addSkinTexture(Canvas canvas, Offset center, double size) {
    final texturePaint = Paint()
      ..color = _getEnhancedSkinColor().withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Add subtle skin texture
    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2) / 20;
      final radius = size * (0.3 + math.Random().nextDouble() * 0.3);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      canvas.drawCircle(Offset(x, y), 0.5, texturePaint);
    }

    // Add freckles if enabled
    if (avatarData.faceData.hasFreckles) {
      _addFreckles(canvas, center, size);
    }
  }

  void _addFreckles(Canvas canvas, Offset center, double size) {
    final frecklePaint = Paint()
      ..color = _getEnhancedSkinColor().withOpacity(0.4);

    final random = math.Random(42); // Fixed seed for consistent freckles
    for (int i = 0; i < 15; i++) {
      final x = center.dx + (random.nextDouble() - 0.5) * size * 0.8;
      final y = center.dy + (random.nextDouble() - 0.5) * size * 0.6;
      final freckleSize = 0.5 + random.nextDouble() * 1.0;
      
      canvas.drawCircle(Offset(x, y), freckleSize, frecklePaint);
    }
  }

  void _drawEnhancedNeck(Canvas canvas, Size size, double headSize) {
    final skinColor = _getEnhancedSkinColor();
    final neckCenter = Offset(0, -size.height * 0.22);
    
    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          skinColor.withOpacity(0.75),
          skinColor,
          skinColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromCenter(
        center: neckCenter,
        width: headSize * 0.5,
        height: headSize * 0.35,
      ));

    // Draw neck with realistic proportions
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: neckCenter,
          width: headSize * 0.45,
          height: headSize * 0.35,
        ),
        const Radius.circular(10),
      ),
      neckPaint,
    );

    // Add neck muscles definition
    _addNeckDefinition(canvas, neckCenter, headSize);
  }

  void _addNeckDefinition(Canvas canvas, Offset center, double headSize) {
    final definitionPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Sternocleidomastoid muscle
    canvas.drawLine(
      Offset(center.dx - headSize * 0.15, center.dy - headSize * 0.1),
      Offset(center.dx - headSize * 0.05, center.dy + headSize * 0.15),
      definitionPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx + headSize * 0.15, center.dy - headSize * 0.1),
      Offset(center.dx + headSize * 0.05, center.dy + headSize * 0.15),
      definitionPaint,
    );
  }

  void _drawEnhancedTorso(Canvas canvas, Size size, double torsoHeight, double shoulderWidth, double waistWidth) {
    final skinColor = _getEnhancedSkinColor();
    final torsoCenter = Offset(0, -size.height * 0.05);
    
    // Create realistic torso with muscle definition
    final torsoPath = Path();
    final torsoTop = -size.height * 0.15;
    final torsoBottom = torsoTop + torsoHeight;
    
    // Enhanced torso shape with realistic curves
    torsoPath.moveTo(-shoulderWidth / 2, torsoTop);
    torsoPath.lineTo(shoulderWidth / 2, torsoTop);
    
    // Right side with realistic body curve
    torsoPath.quadraticBezierTo(
      shoulderWidth / 2, torsoTop + torsoHeight * 0.2,
      shoulderWidth * 0.4, torsoTop + torsoHeight * 0.4,
    );
    torsoPath.quadraticBezierTo(
      waistWidth / 2, torsoTop + torsoHeight * 0.7,
      waistWidth * 0.6, torsoBottom,
    );
    
    // Bottom
    torsoPath.lineTo(-waistWidth * 0.6, torsoBottom);
    
    // Left side
    torsoPath.quadraticBezierTo(
      -waistWidth / 2, torsoTop + torsoHeight * 0.7,
      -shoulderWidth * 0.4, torsoTop + torsoHeight * 0.4,
    );
    torsoPath.quadraticBezierTo(
      -shoulderWidth / 2, torsoTop + torsoHeight * 0.2,
      -shoulderWidth / 2, torsoTop,
    );
    
    torsoPath.close();

    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          skinColor.withOpacity(0.7),
          skinColor,
          skinColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromLTWH(-shoulderWidth/2, torsoTop, shoulderWidth, torsoHeight));

    canvas.drawPath(torsoPath, torsoPaint);
    
    // Add enhanced muscle definition
    _addEnhancedMuscleDefinition(canvas, torsoTop, torsoHeight, shoulderWidth);
  }

  void _addEnhancedMuscleDefinition(Canvas canvas, double torsoTop, double torsoHeight, double shoulderWidth) {
    final musclePaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Pectoral muscles
    final leftPecPath = Path();
    leftPecPath.moveTo(-shoulderWidth * 0.35, torsoTop + torsoHeight * 0.15);
    leftPecPath.quadraticBezierTo(
      -shoulderWidth * 0.2, torsoTop + torsoHeight * 0.2,
      -shoulderWidth * 0.05, torsoTop + torsoHeight * 0.25,
    );
    canvas.drawPath(leftPecPath, musclePaint);
    
    final rightPecPath = Path();
    rightPecPath.moveTo(shoulderWidth * 0.35, torsoTop + torsoHeight * 0.15);
    rightPecPath.quadraticBezierTo(
      shoulderWidth * 0.2, torsoTop + torsoHeight * 0.2,
      shoulderWidth * 0.05, torsoTop + torsoHeight * 0.25,
    );
    canvas.drawPath(rightPecPath, musclePaint);

    // Abdominal muscles
    final absPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Rectus abdominis
    canvas.drawLine(
      Offset(0, torsoTop + torsoHeight * 0.35),
      Offset(0, torsoTop + torsoHeight * 0.85),
      absPaint,
    );

    // Horizontal ab lines
    for (int i = 0; i < 3; i++) {
      final y = torsoTop + torsoHeight * (0.45 + i * 0.15);
      canvas.drawLine(
        Offset(-shoulderWidth * 0.12, y),
        Offset(shoulderWidth * 0.12, y),
        absPaint,
      );
    }

    // Obliques
    final obliquePath = Path();
    obliquePath.moveTo(-shoulderWidth * 0.25, torsoTop + torsoHeight * 0.5);
    obliquePath.quadraticBezierTo(
      -shoulderWidth * 0.15, torsoTop + torsoHeight * 0.7,
      -shoulderWidth * 0.05, torsoTop + torsoHeight * 0.8,
    );
    canvas.drawPath(obliquePath, absPaint);
    
    // Mirror for right side
    final rightObliquePath = Path();
    rightObliquePath.moveTo(shoulderWidth * 0.25, torsoTop + torsoHeight * 0.5);
    rightObliquePath.quadraticBezierTo(
      shoulderWidth * 0.15, torsoTop + torsoHeight * 0.7,
      shoulderWidth * 0.05, torsoTop + torsoHeight * 0.8,
    );
    canvas.drawPath(rightObliquePath, absPaint);
  }

  void _drawEnhancedArms(Canvas canvas, Size size, double shoulderWidth, double torsoHeight) {
    final skinColor = _getEnhancedSkinColor();
    final armLength = torsoHeight * 0.9;
    final upperArmWidth = size.width * 0.09;
    final forearmWidth = size.width * 0.07;
    
    final armPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          skinColor.withOpacity(0.75),
          skinColor,
          skinColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTWH(-shoulderWidth, -size.height * 0.15, shoulderWidth * 2, armLength));

    // Enhanced arms with realistic muscle definition
    _drawEnhancedSingleArm(canvas, true, shoulderWidth, size, armLength, upperArmWidth, forearmWidth, armPaint);
    _drawEnhancedSingleArm(canvas, false, shoulderWidth, size, armLength, upperArmWidth, forearmWidth, armPaint);
  }

  void _drawEnhancedSingleArm(Canvas canvas, bool isLeft, double shoulderWidth, Size size, 
                             double armLength, double upperArmWidth, double forearmWidth, Paint armPaint) {
    final side = isLeft ? -1.0 : 1.0;
    final shoulderX = side * shoulderWidth / 2;
    final shoulderY = -size.height * 0.15;
    
    // Upper arm with realistic shape
    final upperArmPath = Path();
    upperArmPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(shoulderX + side * upperArmWidth * 0.6, shoulderY + armLength * 0.25),
        width: upperArmWidth,
        height: armLength * 0.5,
      ),
      const Radius.circular(upperArmWidth * 0.4),
    ));
    
    canvas.drawPath(upperArmPath, armPaint);
    
    // Bicep definition
    _addBicepDefinition(canvas, shoulderX, shoulderY, side, upperArmWidth, armLength);
    
    // Elbow joint with realistic shape
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(shoulderX + side * upperArmWidth * 0.6, shoulderY + armLength * 0.5),
        width: upperArmWidth * 0.8,
        height: upperArmWidth * 0.6,
      ),
      armPaint,
    );
    
    // Forearm with muscle definition
    final forearmPath = Path();
    forearmPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(shoulderX + side * (upperArmWidth * 0.6 + forearmWidth * 0.3), shoulderY + armLength * 0.75),
        width: forearmWidth,
        height: armLength * 0.5,
      ),
      const Radius.circular(forearmWidth * 0.4),
    ));
    
    canvas.drawPath(forearmPath, armPaint);
    
    // Enhanced hand
    _drawEnhancedHand(canvas, shoulderX, shoulderY, side, upperArmWidth, forearmWidth, armLength, armPaint);
  }

  void _addBicepDefinition(Canvas canvas, double shoulderX, double shoulderY, double side, double upperArmWidth, double armLength) {
    final bicepPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Bicep peak
    final bicepPath = Path();
    bicepPath.moveTo(shoulderX + side * upperArmWidth * 0.3, shoulderY + armLength * 0.15);
    bicepPath.quadraticBezierTo(
      shoulderX + side * upperArmWidth * 0.8, shoulderY + armLength * 0.25,
      shoulderX + side * upperArmWidth * 0.3, shoulderY + armLength * 0.35,
    );
    canvas.drawPath(bicepPath, bicepPaint);
  }

  void _drawEnhancedHand(Canvas canvas, double shoulderX, double shoulderY, double side, 
                        double upperArmWidth, double forearmWidth, double armLength, Paint armPaint) {
    final handCenter = Offset(
      shoulderX + side * (upperArmWidth * 0.6 + forearmWidth * 0.3), 
      shoulderY + armLength,
    );
    
    // Palm
    canvas.drawOval(
      Rect.fromCenter(
        center: handCenter,
        width: forearmWidth * 0.9,
        height: forearmWidth * 1.3,
      ),
      armPaint,
    );
    
    // Fingers
    final fingerPaint = Paint()
      ..color = _getEnhancedSkinColor()
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 4; i++) {
      final fingerX = handCenter.dx + side * (i - 1.5) * forearmWidth * 0.15;
      final fingerY = handCenter.dy + forearmWidth * 0.6;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(fingerX, fingerY),
            width: forearmWidth * 0.12,
            height: forearmWidth * 0.4,
          ),
          const Radius.circular(forearmWidth * 0.06),
        ),
        fingerPaint,
      );
    }
    
    // Thumb
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(handCenter.dx + side * forearmWidth * 0.4, handCenter.dy + forearmWidth * 0.2),
          width: forearmWidth * 0.15,
          height: forearmWidth * 0.3,
        ),
        const Radius.circular(forearmWidth * 0.075),
      ),
      fingerPaint,
    );
  }

  void _drawEnhancedHips(Canvas canvas, Size size, double torsoHeight, double hipWidth) {
    final skinColor = _getEnhancedSkinColor();
    final hipCenter = Offset(0, size.height * 0.08);
    
    final hipsPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          skinColor.withOpacity(0.75),
          skinColor,
          skinColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromCenter(
        center: hipCenter,
        width: hipWidth,
        height: size.height * 0.16,
      ));

    // Enhanced hip shape based on body type
    final hipPath = Path();
    final hipTop = hipCenter.dy - size.height * 0.08;
    final hipBottom = hipCenter.dy + size.height * 0.08;
    
    hipPath.moveTo(-hipWidth * 0.5, hipTop);
    hipPath.lineTo(hipWidth * 0.5, hipTop);
    hipPath.quadraticBezierTo(
      hipWidth * 0.55, hipCenter.dy,
      hipWidth * 0.5, hipBottom,
    );
    hipPath.lineTo(-hipWidth * 0.5, hipBottom);
    hipPath.quadraticBezierTo(
      -hipWidth * 0.55, hipCenter.dy,
      -hipWidth * 0.5, hipTop,
    );
    hipPath.close();
    
    canvas.drawPath(hipPath, hipsPaint);
    
    // Add hip bone definition
    _addHipDefinition(canvas, hipCenter, hipWidth);
  }

  void _addHipDefinition(Canvas canvas, Offset center, double hipWidth) {
    final definitionPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Hip bone lines
    canvas.drawLine(
      Offset(center.dx - hipWidth * 0.3, center.dy - hipWidth * 0.1),
      Offset(center.dx - hipWidth * 0.1, center.dy + hipWidth * 0.1),
      definitionPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx + hipWidth * 0.3, center.dy - hipWidth * 0.1),
      Offset(center.dx + hipWidth * 0.1, center.dy + hipWidth * 0.1),
      definitionPaint,
    );
  }

  void _drawEnhancedLegs(Canvas canvas, Size size, double legHeight, double hipWidth) {
    final skinColor = _getEnhancedSkinColor();
    final legWidth = hipWidth * 0.38;
    
    final legPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          skinColor,
          skinColor.withOpacity(0.95),
          skinColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromLTWH(-hipWidth/2, size.height * 0.16, hipWidth, legHeight));

    // Enhanced legs with realistic muscle definition
    _drawEnhancedSingleLeg(canvas, true, hipWidth, size, legHeight, legWidth, legPaint);
    _drawEnhancedSingleLeg(canvas, false, hipWidth, size, legHeight, legWidth, legPaint);
  }

  void _drawEnhancedSingleLeg(Canvas canvas, bool isLeft, double hipWidth, Size size,
                             double legHeight, double legWidth, Paint legPaint) {
    final side = isLeft ? -1.0 : 1.0;
    final hipX = side * hipWidth * 0.25;
    final hipY = size.height * 0.16;
    
    // Thigh with realistic muscle shape
    final thighPath = Path();
    thighPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(hipX, hipY + legHeight * 0.25),
        width: legWidth,
        height: legHeight * 0.5,
      ),
      const Radius.circular(legWidth * 0.3),
    ));
    
    canvas.drawPath(thighPath, legPaint);
    
    // Quadriceps definition
    _addQuadricepsDefinition(canvas, hipX, hipY, legWidth, legHeight);
    
    // Knee joint with realistic shape
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hipX, hipY + legHeight * 0.5),
        width: legWidth * 0.9,
        height: legWidth * 0.6,
      ),
      legPaint,
    );
    
    // Calf with muscle definition
    final calfPath = Path();
    calfPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(hipX, hipY + legHeight * 0.75),
        width: legWidth * 0.85,
        height: legHeight * 0.5,
      ),
      const Radius.circular(legWidth * 0.25),
    ));
    
    canvas.drawPath(calfPath, legPaint);
    
    // Calf muscle definition
    _addCalfDefinition(canvas, hipX, hipY, legWidth, legHeight);
  }

  void _addQuadricepsDefinition(Canvas canvas, double hipX, double hipY, double legWidth, double legHeight) {
    final quadPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vastus medialis
    canvas.drawLine(
      Offset(hipX - legWidth * 0.15, hipY + legHeight * 0.15),
      Offset(hipX - legWidth * 0.05, hipY + legHeight * 0.45),
      quadPaint,
    );
    
    // Vastus lateralis
    canvas.drawLine(
      Offset(hipX + legWidth * 0.15, hipY + legHeight * 0.15),
      Offset(hipX + legWidth * 0.05, hipY + legHeight * 0.45),
      quadPaint,
    );
    
    // Rectus femoris
    canvas.drawLine(
      Offset(hipX, hipY + legHeight * 0.1),
      Offset(hipX, hipY + legHeight * 0.45),
      quadPaint,
    );
  }

  void _addCalfDefinition(Canvas canvas, double hipX, double hipY, double legWidth, double legHeight) {
    final calfPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Gastrocnemius
    final calfPath = Path();
    calfPath.moveTo(hipX - legWidth * 0.2, hipY + legHeight * 0.55);
    calfPath.quadraticBezierTo(
      hipX, hipY + legHeight * 0.7,
      hipX + legWidth * 0.2, hipY + legHeight * 0.55,
    );
    canvas.drawPath(calfPath, calfPaint);
    
    // Achilles tendon
    canvas.drawLine(
      Offset(hipX, hipY + legHeight * 0.9),
      Offset(hipX, hipY + legHeight * 0.98),
      calfPaint,
    );
  }

  void _drawEnhancedFeet(Canvas canvas, Size size, double legHeight) {
    final skinColor = _getEnhancedSkinColor();
    final footPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          skinColor,
          skinColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(0, size.height * 0.16 + legHeight),
        width: size.width * 0.2,
        height: size.width * 0.1,
      ));

    final footY = size.height * 0.16 + legHeight;
    final footWidth = size.width * 0.09;
    final footLength = size.width * 0.14;

    // Enhanced feet with realistic shape
    _drawRealisticFoot(canvas, Offset(-size.width * 0.06, footY), footLength, footWidth, footPaint, true);
    _drawRealisticFoot(canvas, Offset(size.width * 0.06, footY), footLength, footWidth, footPaint, false);
  }

  void _drawRealisticFoot(Canvas canvas, Offset center, double length, double width, Paint paint, bool isLeft) {
    final footPath = Path();
    
    // Heel
    footPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - length * 0.2),
      width: width * 0.8,
      height: width * 0.6,
    ));
    
    // Arch
    footPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: width * 0.6,
        height: length * 0.6,
      ),
      const Radius.circular(8),
    ));
    
    // Toes
    footPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy + length * 0.3),
      width: width,
      height: width * 0.5,
    ));
    
    canvas.drawPath(footPath, paint);
    
    // Add toe details
    _addToeDetails(canvas, center, length, width);
  }

  void _addToeDetails(Canvas canvas, Offset center, double length, double width) {
    final toePaint = Paint()
      ..color = _getEnhancedSkinColor().withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Individual toes
    for (int i = 0; i < 5; i++) {
      final toeX = center.dx + (i - 2) * width * 0.15;
      final toeY = center.dy + length * 0.35;
      final toeSize = width * (0.08 - i * 0.01);
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(toeX, toeY),
          width: toeSize,
          height: toeSize * 0.8,
        ),
        toePaint,
      );
    }
  }

  void _drawEnhancedFacialFeatures(Canvas canvas, Size size, double headSize) {
    final faceCenter = Offset(0, -size.height * 0.32);
    
    // Enhanced eyes with realistic details
    _drawUltraRealisticEyes(canvas, faceCenter, headSize);
    
    // Enhanced eyebrows with hair-like texture
    _drawRealisticEyebrows(canvas, faceCenter, headSize);
    
    // Enhanced nose with proper 3D structure
    _drawUltraRealisticNose(canvas, faceCenter, headSize);
    
    // Enhanced mouth with detailed lips
    _drawUltraRealisticMouth(canvas, faceCenter, headSize);
    
    // Add dimples if enabled
    if (avatarData.faceData.hasDimples) {
      _addDimples(canvas, faceCenter, headSize);
    }
  }

  void _drawUltraRealisticEyes(Canvas canvas, Offset faceCenter, double headSize) {
    final eyeColor = _getEnhancedEyeColor();
    final baseEyeSize = headSize * 0.09 * avatarData.faceData.eyeSize;
    
    final leftEyeCenter = Offset(faceCenter.dx - headSize * 0.22, faceCenter.dy - headSize * 0.08);
    final rightEyeCenter = Offset(faceCenter.dx + headSize * 0.22, faceCenter.dy - headSize * 0.08);
    
    // Eye sockets with realistic depth
    _drawEyeSocket(canvas, leftEyeCenter, baseEyeSize);
    _drawEyeSocket(canvas, rightEyeCenter, baseEyeSize);
    
    // Eyeballs with sclera
    _drawEyeball(canvas, leftEyeCenter, baseEyeSize);
    _drawEyeball(canvas, rightEyeCenter, baseEyeSize);
    
    // Iris with detailed texture
    _drawDetailedIris(canvas, leftEyeCenter, baseEyeSize, eyeColor);
    _drawDetailedIris(canvas, rightEyeCenter, baseEyeSize, eyeColor);
    
    // Pupils with reflection
    _drawPupilWithReflection(canvas, leftEyeCenter, baseEyeSize);
    _drawPupilWithReflection(canvas, rightEyeCenter, baseEyeSize);
    
    // Eyelashes if enabled
    if (avatarData.faceData.hasEyelashes) {
      _drawRealisticEyelashes(canvas, leftEyeCenter, rightEyeCenter, baseEyeSize);
    }
    
    // Eye highlights and catchlights
    _addEyeHighlights(canvas, leftEyeCenter, rightEyeCenter, baseEyeSize);
  }

  void _drawEyeSocket(Canvas canvas, Offset center, double eyeSize) {
    final socketPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawOval(
      Rect.fromCenter(center: center, width: eyeSize * 3.2, height: eyeSize * 2.4),
      socketPaint,
    );
    
    // Upper eyelid shadow
    final upperLidShadow = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - eyeSize * 0.3),
        width: eyeSize * 2.8,
        height: eyeSize * 0.8,
      ),
      upperLidShadow,
    );
  }

  void _drawEyeball(Canvas canvas, Offset center, double eyeSize) {
    final eyeballPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFF8F8F8),
          const Color(0xFFE8E8E8),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: eyeSize * 2.4, height: eyeSize * 1.8));
    
    canvas.drawOval(
      Rect.fromCenter(center: center, width: eyeSize * 2.4, height: eyeSize * 1.8 * eyeOpenness),
      eyeballPaint,
    );
    
    // Tear duct
    final tearDuctPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(0.6);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - eyeSize * 1.0, center.dy),
        width: eyeSize * 0.3,
        height: eyeSize * 0.2,
      ),
      tearDuctPaint,
    );
  }

  void _drawDetailedIris(Canvas canvas, Offset center, double eyeSize, Color eyeColor) {
    // Iris base
    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          eyeColor.withOpacity(0.9),
          eyeColor,
          eyeColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: eyeSize * 1.4, height: eyeSize * 1.4));
    
    canvas.drawCircle(center, eyeSize * 0.7, irisPaint);
    
    // Iris texture lines
    final texturePaint = Paint()
      ..color = eyeColor.withOpacity(0.4)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      final startX = center.dx + math.cos(angle) * eyeSize * 0.3;
      final startY = center.dy + math.sin(angle) * eyeSize * 0.3;
      final endX = center.dx + math.cos(angle) * eyeSize * 0.65;
      final endY = center.dy + math.sin(angle) * eyeSize * 0.65;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), texturePaint);
    }
    
    // Iris ring
    final ringPaint = Paint()
      ..color = eyeColor.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, eyeSize * 0.65, ringPaint);
  }

  void _drawPupilWithReflection(Canvas canvas, Offset center, double eyeSize) {
    // Pupil
    final pupilPaint = Paint()
      ..color = Colors.black;
    
    canvas.drawCircle(center, eyeSize * 0.35, pupilPaint);
    
    // Main catchlight
    final catchlightPaint = Paint()
      ..color = Colors.white;
    
    canvas.drawCircle(
      Offset(center.dx + eyeSize * 0.15, center.dy - eyeSize * 0.15),
      eyeSize * 0.12,
      catchlightPaint,
    );
    
    // Secondary reflection
    canvas.drawCircle(
      Offset(center.dx - eyeSize * 0.1, center.dy + eyeSize * 0.1),
      eyeSize * 0.05,
      catchlightPaint,
    );
  }

  void _drawRealisticEyelashes(Canvas canvas, Offset leftEye, Offset rightEye, double eyeSize) {
    final lashPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.8)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Upper lashes
    _drawEyelashSet(canvas, leftEye, eyeSize, lashPaint, true, true);
    _drawEyelashSet(canvas, rightEye, eyeSize, lashPaint, false, true);
    
    // Lower lashes
    final lowerLashPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.6)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    _drawEyelashSet(canvas, leftEye, eyeSize, lowerLashPaint, true, false);
    _drawEyelashSet(canvas, rightEye, eyeSize, lowerLashPaint, false, false);
  }

  void _drawEyelashSet(Canvas canvas, Offset eyeCenter, double eyeSize, Paint paint, bool isLeft, bool isUpper) {
    final lashCount = isUpper ? 12 : 8;
    final lashLength = eyeSize * (isUpper ? 0.4 : 0.2);
    final startAngle = isUpper ? -math.pi * 0.8 : math.pi * 0.2;
    final endAngle = isUpper ? -math.pi * 0.2 : math.pi * 0.8;
    
    for (int i = 0; i < lashCount; i++) {
      final t = i / (lashCount - 1);
      final angle = startAngle + (endAngle - startAngle) * t;
      
      final baseX = eyeCenter.dx + math.cos(angle) * eyeSize * 1.1;
      final baseY = eyeCenter.dy + math.sin(angle) * eyeSize * 0.8;
      
      final tipX = baseX + math.cos(angle - (isUpper ? 0.3 : -0.3)) * lashLength;
      final tipY = baseY + math.sin(angle - (isUpper ? 0.3 : -0.3)) * lashLength;
      
      canvas.drawLine(Offset(baseX, baseY), Offset(tipX, tipY), paint);
    }
  }

  void _addEyeHighlights(Canvas canvas, Offset leftEye, Offset rightEye, double eyeSize) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Lower eyelid highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEye.dx, leftEye.dy + eyeSize * 0.6),
        width: eyeSize * 1.8,
        height: eyeSize * 0.3,
      ),
      highlightPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEye.dx, rightEye.dy + eyeSize * 0.6),
        width: eyeSize * 1.8,
        height: eyeSize * 0.3,
      ),
      highlightPaint,
    );
  }

  void _drawRealisticEyebrows(Canvas canvas, Offset faceCenter, double headSize) {
    final hairColor = _getEnhancedHairColor();
    final eyebrowPaint = Paint()
      ..color = hairColor
      ..strokeWidth = headSize * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final eyebrowY = faceCenter.dy - headSize * 0.22;
    
    // Left eyebrow with individual hairs
    _drawDetailedEyebrow(canvas, faceCenter.dx - headSize * 0.22, eyebrowY, headSize, eyebrowPaint, true);
    
    // Right eyebrow with individual hairs
    _drawDetailedEyebrow(canvas, faceCenter.dx + headSize * 0.22, eyebrowY, headSize, eyebrowPaint, false);
  }

  void _drawDetailedEyebrow(Canvas canvas, double centerX, double centerY, double headSize, Paint paint, bool isLeft) {
    final browWidth = headSize * 0.35;
    final browHeight = headSize * 0.08;
    final hairCount = 25;
    
    for (int i = 0; i < hairCount; i++) {
      final t = i / (hairCount - 1);
      final x = centerX + (isLeft ? -browWidth/2 : -browWidth/2) + browWidth * t;
      
      // Create natural eyebrow arch
      final archHeight = math.sin(t * math.pi) * browHeight;
      final y = centerY - archHeight * 0.5;
      
      // Hair direction varies across the brow
      final hairAngle = isLeft ? 
        (t < 0.3 ? -0.3 : (t > 0.7 ? 0.3 : 0)) :
        (t < 0.3 ? 0.3 : (t > 0.7 ? -0.3 : 0));
      
      final hairLength = headSize * (0.03 + math.Random(i).nextDouble() * 0.02);
      final endX = x + math.cos(hairAngle) * hairLength;
      final endY = y + math.sin(hairAngle) * hairLength;
      
      canvas.drawLine(Offset(x, y), Offset(endX, endY), paint);
    }
  }

  void _drawUltraRealisticNose(Canvas canvas, Offset faceCenter, double headSize) {
    final skinColor = _getEnhancedSkinColor();
    final noseSize = avatarData.faceData.noseSize;
    
    // Nose bridge with realistic shading
    final noseBridgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          skinColor.withOpacity(0.9),
          skinColor.withOpacity(0.7),
          skinColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.05),
        width: headSize * 0.12 * noseSize,
        height: headSize * 0.3,
      ));
    
    // Nose bridge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.05),
          width: headSize * 0.08 * noseSize,
          height: headSize * 0.25,
        ),
        const Radius.circular(6),
      ),
      noseBridgePaint,
    );
    
    // Nose tip
    final noseTipPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          skinColor,
          skinColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.15),
        width: headSize * 0.15 * noseSize,
        height: headSize * 0.1,
      ));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.15),
        width: headSize * 0.12 * noseSize,
        height: headSize * 0.08,
      ),
      noseTipPaint,
    );
    
    // Nostrils with realistic shape
    _drawRealisticNostrils(canvas, faceCenter, headSize, noseSize);
    
    // Nose highlight
    final noseHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(faceCenter.dx - headSize * 0.01, faceCenter.dy + headSize * 0.03),
          width: headSize * 0.03,
          height: headSize * 0.15,
        ),
        const Radius.circular(2),
      ),
      noseHighlightPaint,
    );
  }

  void _drawRealisticNostrils(Canvas canvas, Offset faceCenter, double headSize, double noseSize) {
    final nostrilPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final nostrilY = faceCenter.dy + headSize * 0.15;
    final nostrilWidth = headSize * 0.025 * noseSize;
    final nostrilHeight = headSize * 0.02;
    
    // Left nostril
    final leftNostrilPath = Path();
    leftNostrilPath.addOval(Rect.fromCenter(
      center: Offset(faceCenter.dx - headSize * 0.035 * noseSize, nostrilY),
      width: nostrilWidth,
      height: nostrilHeight,
    ));
    canvas.drawPath(leftNostrilPath, nostrilPaint);
    
    // Right nostril
    final rightNostrilPath = Path();
    rightNostrilPath.addOval(Rect.fromCenter(
      center: Offset(faceCenter.dx + headSize * 0.035 * noseSize, nostrilY),
      width: nostrilWidth,
      height: nostrilHeight,
    ));
    canvas.drawPath(rightNostrilPath, nostrilPaint);
    
    // Nostril shadows for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx - headSize * 0.035 * noseSize, nostrilY + headSize * 0.01),
        width: nostrilWidth * 1.5,
        height: nostrilHeight * 0.5,
      ),
      shadowPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx + headSize * 0.035 * noseSize, nostrilY + headSize * 0.01),
        width: nostrilWidth * 1.5,
        height: nostrilHeight * 0.5,
      ),
      shadowPaint,
    );
  }

  void _drawUltraRealisticMouth(Canvas canvas, Offset faceCenter, double headSize) {
    final lipColor = _getEnhancedLipColor();
    final mouthSize = avatarData.faceData.mouthSize;
    final mouthCenter = Offset(faceCenter.dx, faceCenter.dy + headSize * 0.28);
    
    // Mouth shadow for depth
    final mouthShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: mouthCenter,
          width: headSize * 0.28 * mouthSize,
          height: headSize * 0.06,
        ),
        const Radius.circular(8),
      ),
      mouthShadowPaint,
    );
    
    // Upper lip with realistic shape
    _drawRealisticUpperLip(canvas, mouthCenter, headSize, mouthSize, lipColor);
    
    // Lower lip with volume
    _drawRealisticLowerLip(canvas, mouthCenter, headSize, mouthSize, lipColor);
    
    // Lip line
    _drawLipLine(canvas, mouthCenter, headSize, mouthSize);
    
    // Lip highlights
    _addLipHighlights(canvas, mouthCenter, headSize, mouthSize);
  }

  void _drawRealisticUpperLip(Canvas canvas, Offset center, double headSize, double mouthSize, Color lipColor) {
    final upperLipPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lipColor.withOpacity(0.8),
          lipColor,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy - headSize * 0.02),
        width: headSize * 0.25 * mouthSize,
        height: headSize * 0.04,
      ));

    final upperLipPath = Path();
    final lipWidth = headSize * 0.12 * mouthSize;
    
    // Cupid's bow
    upperLipPath.moveTo(center.dx - lipWidth, center.dy - headSize * 0.01);
    upperLipPath.quadraticBezierTo(
      center.dx - lipWidth * 0.3, center.dy - headSize * 0.025,
      center.dx - lipWidth * 0.15, center.dy - headSize * 0.015,
    );
    upperLipPath.quadraticBezierTo(
      center.dx, center.dy - headSize * 0.03,
      center.dx + lipWidth * 0.15, center.dy - headSize * 0.015,
    );
    upperLipPath.quadraticBezierTo(
      center.dx + lipWidth * 0.3, center.dy - headSize * 0.025,
      center.dx + lipWidth, center.dy - headSize * 0.01,
    );
    upperLipPath.quadraticBezierTo(
      center.dx, center.dy + headSize * 0.005,
      center.dx - lipWidth, center.dy - headSize * 0.01,
    );
    
    canvas.drawPath(upperLipPath, upperLipPaint);
  }

  void _drawRealisticLowerLip(Canvas canvas, Offset center, double headSize, double mouthSize, Color lipColor) {
    final lowerLipPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lipColor,
          lipColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + headSize * 0.025),
        width: headSize * 0.22 * mouthSize,
        height: headSize * 0.05,
      ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + headSize * 0.025),
          width: headSize * 0.2 * mouthSize,
          height: headSize * 0.045,
        ),
        const Radius.circular(6),
      ),
      lowerLipPaint,
    );
  }

  void _drawLipLine(Canvas canvas, Offset center, double headSize, double mouthSize) {
    final lipLinePaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lipLineWidth = headSize * 0.18 * mouthSize;
    
    final lipLinePath = Path();
    lipLinePath.moveTo(center.dx - lipLineWidth, center.dy);
    lipLinePath.quadraticBezierTo(
      center.dx, center.dy + headSize * 0.008,
      center.dx + lipLineWidth, center.dy,
    );
    
    canvas.drawPath(lipLinePath, lipLinePaint);
  }

  void _addLipHighlights(Canvas canvas, Offset center, double headSize, double mouthSize) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Upper lip highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headSize * 0.015),
          width: headSize * 0.15 * mouthSize,
          height: headSize * 0.02,
        ),
        const Radius.circular(3),
      ),
      highlightPaint,
    );
    
    // Lower lip highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + headSize * 0.015),
          width: headSize * 0.12 * mouthSize,
          height: headSize * 0.025,
        ),
        const Radius.circular(4),
      ),
      highlightPaint,
    );
  }

  void _addDimples(Canvas canvas, Offset faceCenter, double headSize) {
    final dimplePaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Left dimple
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx - headSize * 0.25, faceCenter.dy + headSize * 0.15),
        width: headSize * 0.04,
        height: headSize * 0.02,
      ),
      dimplePaint,
    );
    
    // Right dimple
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx + headSize * 0.25, faceCenter.dy + headSize * 0.15),
        width: headSize * 0.04,
        height: headSize * 0.02,
      ),
      dimplePaint,
    );
  }

  void _drawEnhancedHair(Canvas canvas, Size size, double headSize) {
    final hairColor = _getEnhancedHairColor();
    final faceCenter = Offset(0, -size.height * 0.32);
    
    // Create ultra-realistic hair with individual strands
    final hairPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.8),
        radius: 1.5,
        colors: [
          hairColor,
          hairColor.withOpacity(0.9),
          hairColor.withOpacity(0.7),
          hairColor.withOpacity(0.5),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCenter(
        center: faceCenter,
        width: headSize * 3,
        height: headSize * 3,
      ));

    // Draw hair based on style and length
    _drawHairByStyle(canvas, faceCenter, headSize, hairPaint);
    
    // Add hair texture and individual strands
    _addAdvancedHairTexture(canvas, faceCenter, headSize);
    
    // Add highlights if enabled
    if (avatarData.hairData.hasHighlights) {
      _addHairHighlights(canvas, faceCenter, headSize);
    }
    
    // Add bangs if enabled
    if (avatarData.hairData.hasBangs) {
      _drawBangs(canvas, faceCenter, headSize, hairPaint);
    }
  }

  void _drawHairByStyle(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    switch (avatarData.hairData.hairLength) {
      case 'short':
        _drawEnhancedShortHair(canvas, faceCenter, headSize, hairPaint);
        break;
      case 'medium':
        _drawEnhancedMediumHair(canvas, faceCenter, headSize, hairPaint);
        break;
      case 'long':
        _drawEnhancedLongHair(canvas, faceCenter, headSize, hairPaint);
        break;
      case 'extra-long':
        _drawEnhancedExtraLongHair(canvas, faceCenter, headSize, hairPaint);
        break;
    }
  }

  void _drawEnhancedShortHair(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    final hairPath = Path();
    
    // Create natural short hair shape
    hairPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy - headSize * 0.12),
        width: headSize * 1.5,
        height: headSize * 1.2,
      ),
      Radius.circular(headSize * 0.35),
    ));
    
    canvas.drawPath(hairPath, hairPaint);
    
    // Add volume at the top
    _addHairVolume(canvas, faceCenter, headSize, 0.8);
  }

  void _drawEnhancedMediumHair(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    final hairPath = Path();
    
    // Create flowing medium hair
    hairPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy - headSize * 0.05),
        width: headSize * 1.7,
        height: headSize * 2.0,
      ),
      Radius.circular(headSize * 0.45),
    ));
    
    canvas.drawPath(hairPath, hairPaint);
    
    // Add side wisps
    _addHairWisps(canvas, faceCenter, headSize, 1.2);
    _addHairVolume(canvas, faceCenter, headSize, 1.0);
  }

  void _drawEnhancedLongHair(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    final hairPath = Path();
    
    // Create long flowing hair
    hairPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.3),
        width: headSize * 1.9,
        height: headSize * 3.2,
      ),
      Radius.circular(headSize * 0.55),
    ));
    
    canvas.drawPath(hairPath, hairPaint);
    
    // Add flowing sections
    _addFlowingHairSections(canvas, faceCenter, headSize);
    _addHairVolume(canvas, faceCenter, headSize, 1.2);
  }

  void _drawEnhancedExtraLongHair(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    final hairPath = Path();
    
    // Create extra long cascading hair
    hairPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy + headSize * 0.6),
        width: headSize * 2.1,
        height: headSize * 4.0,
      ),
      Radius.circular(headSize * 0.65),
    ));
    
    canvas.drawPath(hairPath, hairPaint);
    
    // Add cascading layers
    _addCascadingHairLayers(canvas, faceCenter, headSize);
    _addHairVolume(canvas, faceCenter, headSize, 1.4);
  }

  void _addHairVolume(Canvas canvas, Offset faceCenter, double headSize, double volumeMultiplier) {
    final volumePaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCenter.dx, faceCenter.dy - headSize * 0.4),
        width: headSize * 0.8 * volumeMultiplier,
        height: headSize * 0.3 * volumeMultiplier,
      ),
      volumePaint,
    );
  }

  void _addHairWisps(Canvas canvas, Offset faceCenter, double headSize, double lengthMultiplier) {
    final wispPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Left side wisps
    for (int i = 0; i < 5; i++) {
      final startX = faceCenter.dx - headSize * (0.6 + i * 0.1);
      final startY = faceCenter.dy - headSize * (0.2 - i * 0.05);
      final endX = startX - headSize * 0.2;
      final endY = startY + headSize * 0.4 * lengthMultiplier;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), wispPaint);
    }
    
    // Right side wisps
    for (int i = 0; i < 5; i++) {
      final startX = faceCenter.dx + headSize * (0.6 + i * 0.1);
      final startY = faceCenter.dy - headSize * (0.2 - i * 0.05);
      final endX = startX + headSize * 0.2;
      final endY = startY + headSize * 0.4 * lengthMultiplier;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), wispPaint);
    }
  }

  void _addFlowingHairSections(Canvas canvas, Offset faceCenter, double headSize) {
    final sectionPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.8)
      ..strokeWidth = headSize * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create flowing hair sections
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final startX = faceCenter.dx + math.cos(angle) * headSize * 0.6;
      final startY = faceCenter.dy + math.sin(angle) * headSize * 0.4;
      
      final flowPath = Path();
      flowPath.moveTo(startX, startY);
      flowPath.quadraticBezierTo(
        startX + math.cos(angle) * headSize * 0.8,
        startY + math.sin(angle) * headSize * 0.8 + headSize * 0.5,
        startX + math.cos(angle) * headSize * 1.2,
        startY + math.sin(angle) * headSize * 1.2 + headSize * 1.0,
      );
      
      canvas.drawPath(flowPath, sectionPaint);
    }
  }

  void _addCascadingHairLayers(Canvas canvas, Offset faceCenter, double headSize) {
    final layerPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.6)
      ..strokeWidth = headSize * 0.06
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create cascading layers
    for (int layer = 0; layer < 4; layer++) {
      final layerY = faceCenter.dy + headSize * (0.5 + layer * 0.8);
      final layerWidth = headSize * (1.8 - layer * 0.2);
      
      final layerPath = Path();
      layerPath.moveTo(faceCenter.dx - layerWidth / 2, layerY);
      layerPath.quadraticBezierTo(
        faceCenter.dx, layerY + headSize * 0.3,
        faceCenter.dx + layerWidth / 2, layerY,
      );
      
      canvas.drawPath(layerPath, layerPaint);
    }
  }

  void _addAdvancedHairTexture(Canvas canvas, Offset faceCenter, double headSize) {
    final texturePaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add individual hair strands
    final random = math.Random(42); // Fixed seed for consistency
    for (int i = 0; i < 50; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final radius = headSize * (0.4 + random.nextDouble() * 0.8);
      final startX = faceCenter.dx + math.cos(angle) * radius;
      final startY = faceCenter.dy + math.sin(angle) * radius * 0.6;
      
      final strandLength = headSize * (0.1 + random.nextDouble() * 0.3);
      final strandAngle = angle + (random.nextDouble() - 0.5) * 0.5;
      final endX = startX + math.cos(strandAngle) * strandLength;
      final endY = startY + math.sin(strandAngle) * strandLength;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), texturePaint);
    }
  }

  void _addHairHighlights(Canvas canvas, Offset faceCenter, double headSize) {
    final highlightColor = _getHairHighlightColor();
    final highlightPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Add natural-looking highlights
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final x = faceCenter.dx + math.cos(angle) * headSize * 0.5;
      final y = faceCenter.dy + math.sin(angle) * headSize * 0.3;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: headSize * 0.2,
          height: headSize * 0.4,
        ),
        highlightPaint,
      );
    }
  }

  void _drawBangs(Canvas canvas, Offset faceCenter, double headSize, Paint hairPaint) {
    final bangsPath = Path();
    
    // Create natural-looking bangs
    bangsPath.moveTo(faceCenter.dx - headSize * 0.6, faceCenter.dy - headSize * 0.5);
    bangsPath.quadraticBezierTo(
      faceCenter.dx, faceCenter.dy - headSize * 0.3,
      faceCenter.dx + headSize * 0.6, faceCenter.dy - headSize * 0.5,
    );
    bangsPath.quadraticBezierTo(
      faceCenter.dx + headSize * 0.4, faceCenter.dy - headSize * 0.15,
      faceCenter.dx + headSize * 0.2, faceCenter.dy - headSize * 0.1,
    );
    bangsPath.quadraticBezierTo(
      faceCenter.dx, faceCenter.dy - headSize * 0.12,
      faceCenter.dx - headSize * 0.2, faceCenter.dy - headSize * 0.1,
    );
    bangsPath.quadraticBezierTo(
      faceCenter.dx - headSize * 0.4, faceCenter.dy - headSize * 0.15,
      faceCenter.dx - headSize * 0.6, faceCenter.dy - headSize * 0.5,
    );
    
    canvas.drawPath(bangsPath, hairPaint);
    
    // Add individual bang strands
    _addBangStrands(canvas, faceCenter, headSize);
  }

  void _addBangStrands(Canvas canvas, Offset faceCenter, double headSize) {
    final strandPaint = Paint()
      ..color = _getEnhancedHairColor().withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final t = i / 11.0;
      final startX = faceCenter.dx + (t - 0.5) * headSize * 1.0;
      final startY = faceCenter.dy - headSize * 0.45;
      
      final endX = startX + (math.Random(i).nextDouble() - 0.5) * headSize * 0.1;
      final endY = faceCenter.dy - headSize * (0.08 + math.Random(i).nextDouble() * 0.05);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), strandPaint);
    }
  }

  void _drawEnhancedClothing(Canvas canvas, Size size, double torsoHeight, double bodyWidth) {
    if (clothingItem == null) return;
    
    final clothingColor = _getEnhancedClothingColor();
    final category = clothingItem!.category.toLowerCase();
    
    // Create realistic fabric shader
    final fabricPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          clothingColor.withOpacity(0.8),
          clothingColor,
          clothingColor.withOpacity(0.9),
          clothingColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCenter(
        center: Offset(0, 0),
        width: bodyWidth * 1.5,
        height: torsoHeight * 1.2,
      ));

    switch (category) {
      case 'tops':
      case 'top':
        _drawEnhancedTop(canvas, size, torsoHeight, bodyWidth, fabricPaint);
        break;
      case 'bottoms':
      case 'bottom':
        _drawEnhancedBottom(canvas, size, bodyWidth, fabricPaint);
        break;
      case 'outfits':
      case 'dress':
        _drawEnhancedDress(canvas, size, torsoHeight, bodyWidth, fabricPaint);
        break;
      case 'jackets':
      case 'jacket':
        _drawEnhancedJacket(canvas, size, torsoHeight, bodyWidth, fabricPaint);
        break;
    }
    
    // Add fabric texture and wrinkles
    _addFabricDetails(canvas, size, torsoHeight, bodyWidth);
  }

  void _drawEnhancedTop(Canvas canvas, Size size, double torsoHeight, double bodyWidth, Paint fabricPaint) {
    final topPath = Path();
    final topTop = -size.height * 0.15;
    final topBottom = topTop + torsoHeight * 0.75;
    
    // Create fitted top with realistic draping
    topPath.moveTo(-bodyWidth * 0.65, topTop);
    topPath.lineTo(bodyWidth * 0.65, topTop);
    topPath.quadraticBezierTo(
      bodyWidth * 0.55, topTop + torsoHeight * 0.15,
      bodyWidth * 0.45, topTop + torsoHeight * 0.4,
    );
    topPath.quadraticBezierTo(
      bodyWidth * 0.4, topTop + torsoHeight * 0.6,
      bodyWidth * 0.42, topBottom,
    );
    topPath.lineTo(-bodyWidth * 0.42, topBottom);
    topPath.quadraticBezierTo(
      -bodyWidth * 0.4, topTop + torsoHeight * 0.6,
      -bodyWidth * 0.45, topTop + torsoHeight * 0.4,
    );
    topPath.quadraticBezierTo(
      -bodyWidth * 0.55, topTop + torsoHeight * 0.15,
      -bodyWidth * 0.65, topTop,
    );
    topPath.close();
    
    canvas.drawPath(topPath, fabricPaint);
    
    // Add neckline
    _addNeckline(canvas, topTop, bodyWidth);
    
    // Add sleeves if applicable
    _addSleeves(canvas, size, topTop, torsoHeight, bodyWidth, fabricPaint);
  }

  void _addNeckline(Canvas canvas, double topTop, double bodyWidth) {
    final necklinePaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Scoop neckline
    final necklinePath = Path();
    necklinePath.moveTo(-bodyWidth * 0.2, topTop + bodyWidth * 0.05);
    necklinePath.quadraticBezierTo(
      0, topTop + bodyWidth * 0.15,
      bodyWidth * 0.2, topTop + bodyWidth * 0.05,
    );
    
    canvas.drawPath(necklinePath, necklinePaint);
  }

  void _addSleeves(Canvas canvas, Size size, double topTop, double torsoHeight, double bodyWidth, Paint fabricPaint) {
    // Short sleeves
    final sleeveLength = torsoHeight * 0.3;
    
    // Left sleeve
    final leftSleevePath = Path();
    leftSleevePath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-bodyWidth * 0.8, topTop + sleeveLength * 0.5),
        width: bodyWidth * 0.3,
        height: sleeveLength,
      ),
      const Radius.circular(8),
    ));
    canvas.drawPath(leftSleevePath, fabricPaint);
    
    // Right sleeve
    final rightSleevePath = Path();
    rightSleevePath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(bodyWidth * 0.8, topTop + sleeveLength * 0.5),
        width: bodyWidth * 0.3,
        height: sleeveLength,
      ),
      const Radius.circular(8),
    ));
    canvas.drawPath(rightSleevePath, fabricPaint);
  }

  void _drawEnhancedBottom(Canvas canvas, Size size, double bodyWidth, Paint fabricPaint) {
    final bottomTop = size.height * 0.05;
    final bottomBottom = size.height * 0.38;
    
    // Create realistic pants/skirt shape
    final bottomPath = Path();
    bottomPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(-bodyWidth * 0.38, bottomTop, bodyWidth * 0.76, bottomBottom - bottomTop),
      const Radius.circular(12),
    ));
    
    canvas.drawPath(bottomPath, fabricPaint);
    
    // Add waistband
    _addWaistband(canvas, bottomTop, bodyWidth);
    
    // Add seams
    _addSeams(canvas, bottomTop, bottomBottom, bodyWidth);
  }

  void _addWaistband(Canvas canvas, double bottomTop, double bodyWidth) {
    final waistbandPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-bodyWidth * 0.35, bottomTop + bodyWidth * 0.05),
      Offset(bodyWidth * 0.35, bottomTop + bodyWidth * 0.05),
      waistbandPaint,
    );
  }

  void _addSeams(Canvas canvas, double bottomTop, double bottomBottom, double bodyWidth) {
    final seamPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Inseam
    canvas.drawLine(
      Offset(0, bottomTop + bodyWidth * 0.1),
      Offset(0, bottomBottom - bodyWidth * 0.05),
      seamPaint,
    );
    
    // Side seams
    canvas.drawLine(
      Offset(-bodyWidth * 0.35, bottomTop + bodyWidth * 0.1),
      Offset(-bodyWidth * 0.35, bottomBottom - bodyWidth * 0.05),
      seamPaint,
    );
    
    canvas.drawLine(
      Offset(bodyWidth * 0.35, bottomTop + bodyWidth * 0.1),
      Offset(bodyWidth * 0.35, bottomBottom - bodyWidth * 0.05),
      seamPaint,
    );
  }

  void _drawEnhancedDress(Canvas canvas, Size size, double torsoHeight, double bodyWidth, Paint fabricPaint) {
    final dressPath = Path();
    final dressTop = -size.height * 0.15;
    final dressBottom = size.height * 0.32;
    
    // Create flowing dress silhouette
    dressPath.moveTo(-bodyWidth * 0.65, dressTop);
    dressPath.lineTo(bodyWidth * 0.65, dressTop);
    dressPath.quadraticBezierTo(
      bodyWidth * 0.7, dressTop + (dressBottom - dressTop) * 0.2,
      bodyWidth * 0.8, dressTop + (dressBottom - dressTop) * 0.5,
    );
    dressPath.quadraticBezierTo(
      bodyWidth * 0.95, dressTop + (dressBottom - dressTop) * 0.8,
      bodyWidth * 1.0, dressBottom,
    );
    dressPath.lineTo(-bodyWidth * 1.0, dressBottom);
    dressPath.quadraticBezierTo(
      -bodyWidth * 0.95, dressTop + (dressBottom - dressTop) * 0.8,
      -bodyWidth * 0.8, dressTop + (dressBottom - dressTop) * 0.5,
    );
    dressPath.quadraticBezierTo(
      -bodyWidth * 0.7, dressTop + (dressBottom - dressTop) * 0.2,
      -bodyWidth * 0.65, dressTop,
    );
    dressPath.close();
    
    canvas.drawPath(dressPath, fabricPaint);
    
    // Add dress details
    _addDressDetails(canvas, dressTop, dressBottom, bodyWidth);
  }

  void _addDressDetails(Canvas canvas, double dressTop, double dressBottom, double bodyWidth) {
    // Add waist definition
    final waistPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final waistY = dressTop + (dressBottom - dressTop) * 0.4;
    canvas.drawLine(
      Offset(-bodyWidth * 0.4, waistY),
      Offset(bodyWidth * 0.4, waistY),
      waistPaint,
    );
    
    // Add hem detail
    canvas.drawLine(
      Offset(-bodyWidth * 0.95, dressBottom - bodyWidth * 0.02),
      Offset(bodyWidth * 0.95, dressBottom - bodyWidth * 0.02),
      waistPaint,
    );
  }

  void _drawEnhancedJacket(Canvas canvas, Size size, double torsoHeight, double bodyWidth, Paint fabricPaint) {
    final jacketPath = Path();
    final jacketTop = -size.height * 0.15;
    final jacketBottom = jacketTop + torsoHeight * 0.85;
    
    // Create structured jacket shape
    jacketPath.moveTo(-bodyWidth * 0.75, jacketTop);
    jacketPath.lineTo(bodyWidth * 0.75, jacketTop);
    jacketPath.lineTo(bodyWidth * 0.65, jacketTop + torsoHeight * 0.12);
    jacketPath.lineTo(bodyWidth * 0.55, jacketBottom);
    jacketPath.lineTo(-bodyWidth * 0.55, jacketBottom);
    jacketPath.lineTo(-bodyWidth * 0.65, jacketTop + torsoHeight * 0.12);
    jacketPath.close();
    
    canvas.drawPath(jacketPath, fabricPaint);
    
    // Add jacket details
    _addJacketDetails(canvas, jacketTop, jacketBottom, torsoHeight, bodyWidth);
  }

  void _addJacketDetails(Canvas canvas, double jacketTop, double jacketBottom, double torsoHeight, double bodyWidth) {
    final detailPaint = Paint()
      ..color = _getEnhancedClothingColor().withOpacity(0.9);

    // Lapels
    final leftLapelPath = Path();
    leftLapelPath.moveTo(-bodyWidth * 0.65, jacketTop);
    leftLapelPath.lineTo(-bodyWidth * 0.35, jacketTop + torsoHeight * 0.25);
    leftLapelPath.lineTo(-bodyWidth * 0.45, jacketTop + torsoHeight * 0.35);
    leftLapelPath.lineTo(-bodyWidth * 0.65, jacketTop + torsoHeight * 0.12);
    leftLapelPath.close();
    canvas.drawPath(leftLapelPath, detailPaint);
    
    final rightLapelPath = Path();
    rightLapelPath.moveTo(bodyWidth * 0.65, jacketTop);
    rightLapelPath.lineTo(bodyWidth * 0.35, jacketTop + torsoHeight * 0.25);
    rightLapelPath.lineTo(bodyWidth * 0.45, jacketTop + torsoHeight * 0.35);
    rightLapelPath.lineTo(bodyWidth * 0.65, jacketTop + torsoHeight * 0.12);
    rightLapelPath.close();
    canvas.drawPath(rightLapelPath, detailPaint);
    
    // Buttons
    final buttonPaint = Paint()
      ..color = Colors.black.withOpacity(0.8);
    
    for (int i = 0; i < 3; i++) {
      final buttonY = jacketTop + torsoHeight * (0.3 + i * 0.15);
      canvas.drawCircle(Offset(bodyWidth * 0.15, buttonY), bodyWidth * 0.02, buttonPaint);
    }
    
    // Pockets
    final pocketPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-bodyWidth * 0.3, jacketTop + torsoHeight * 0.6),
          width: bodyWidth * 0.15,
          height: bodyWidth * 0.1,
        ),
        const Radius.circular(3),
      ),
      pocketPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bodyWidth * 0.3, jacketTop + torsoHeight * 0.6),
          width: bodyWidth * 0.15,
          height: bodyWidth * 0.1,
        ),
        const Radius.circular(3),
      ),
      pocketPaint,
    );
  }

  void _addFabricDetails(Canvas canvas, Size size, double torsoHeight, double bodyWidth) {
    final wrinklePaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Add subtle fabric wrinkles
    for (int i = 0; i < 8; i++) {
      final startX = -bodyWidth * 0.4 + (i / 7) * bodyWidth * 0.8;
      final startY = -size.height * 0.1 + (i % 3) * torsoHeight * 0.2;
      final endX = startX + (math.Random(i).nextDouble() - 0.5) * bodyWidth * 0.1;
      final endY = startY + torsoHeight * 0.15;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), wrinklePaint);
    }
  }

  void _drawEnvironmentalLighting(Canvas canvas, Size size) {
    // Rim lighting effect
    final rimLightPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-size.width * 0.3, -size.height * 0.2),
        width: size.width * 0.8,
        height: size.height * 1.2,
      ),
      rimLightPaint,
    );
    
    // Ambient occlusion
    final aoShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.1, size.height * 0.1),
        width: size.width * 0.6,
        height: size.height * 1.0,
      ),
      aoShadowPaint,
    );
  }

  // Enhanced color helper methods
  Color _getEnhancedSkinColor() {
    const colors = {
      'fair': Color(0xFFFDBCB4),
      'light': Color(0xFFEDB98A),
      'medium': Color(0xFFD08B5B),
      'tan': Color(0xFFAE7242),
      'dark': Color(0xFF8D5524),
      'deep': Color(0xFF654321),
    };
    return colors[avatarData.skinTone] ?? colors['medium']!;
  }

  Color _getEnhancedEyeColor() {
    const colors = {
      'brown': Color(0xFF8B4513),
      'blue': Color(0xFF4169E1),
      'green': Color(0xFF228B22),
      'hazel': Color(0xFF8E7618),
      'gray': Color(0xFF708090),
      'amber': Color(0xFFFFBF00),
      'violet': Color(0xFF8A2BE2),
    };
    return colors[avatarData.faceData.eyeColor] ?? colors['brown']!;
  }

  Color _getEnhancedHairColor() {
    const colors = {
      'black': Color(0xFF000000),
      'brown': Color(0xFF8B4513),
      'blonde': Color(0xFFFAD5A5),
      'red': Color(0xFFDC143C),
      'auburn': Color(0xFFA52A2A),
      'gray': Color(0xFF808080),
      'white': Color(0xFFE8E8E8),
      'platinum': Color(0xFFE5E4E2),
    };
    return colors[avatarData.hairData.hairColor] ?? colors['brown']!;
  }

  Color _getHairHighlightColor() {
    if (avatarData.hairData.highlightColor != null) {
      const colors = {
        'blonde': Color(0xFFFAD5A5),
        'caramel': Color(0xFFD2691E),
        'red': Color(0xFFDC143C),
        'copper': Color(0xFFB87333),
        'platinum': Color(0xFFE5E4E2),
      };
      return colors[avatarData.hairData.highlightColor] ?? const Color(0xFFFAD5A5);
    }
    return _getEnhancedHairColor().withOpacity(0.6);
  }

  Color _getEnhancedLipColor() {
    const colors = {
      'natural': Color(0xFFFFB6C1),
      'pink': Color(0xFFFFB6C1),
      'red': Color(0xFFDC143C),
      'coral': Color(0xFFFF7F50),
      'berry': Color(0xFF8B008B),
      'nude': Color(0xFFDEB887),
      'rose': Color(0xFFFF69B4),
    };
    return colors[avatarData.faceData.lipColor] ?? colors['natural']!;
  }

  Color _getEnhancedClothingColor() {
    if (clothingItem?.colors.isNotEmpty == true) {
      const colorMap = {
        'black': Color(0xFF000000),
        'white': Color(0xFFFFFFFF),
        'red': Color(0xFFFF0000),
        'blue': Color(0xFF0000FF),
        'green': Color(0xFF00FF00),
        'pink': Color(0xFFFFC0CB),
        'purple': Color(0xFF800080),
        'yellow': Color(0xFFFFFF00),
        'orange': Color(0xFFFFA500),
        'brown': Color(0xFFA52A2A),
        'gray': Color(0xFF808080),
        'navy': Color(0xFF000080),
        'maroon': Color(0xFF800000),
        'teal': Color(0xFF008080),
        'olive': Color(0xFF808000),
      };
      
      final firstColor = clothingItem!.colors.first.toLowerCase();
      return colorMap[firstColor] ?? const Color(0xFF9C27B0);
    }
    return const Color(0xFF9C27B0);
  }

  double _getEnhancedBodyWidth(double totalWidth) {
    const widths = {
      'slim': 0.32,
      'medium': 0.42,
      'curvy': 0.52,
      'athletic': 0.48,
    };
    return totalWidth * (widths[avatarData.bodyType] ?? 0.42);
  }

  double _getShoulderMultiplier() {
    const multipliers = {
      'slim': 1.3,
      'medium': 1.4,
      'curvy': 1.35,
      'athletic': 1.5,
    };
    return multipliers[avatarData.bodyType] ?? 1.4;
  }

  double _getWaistMultiplier() {
    const multipliers = {
      'slim': 0.75,
      'medium': 0.8,
      'curvy': 0.85,
      'athletic': 0.78,
    };
    return multipliers[avatarData.bodyType] ?? 0.8;
  }

  double _getHipMultiplier() {
    const multipliers = {
      'slim': 1.05,
      'medium': 1.1,
      'curvy': 1.25,
      'athletic': 1.15,
    };
    return multipliers[avatarData.bodyType] ?? 1.1;
  }

  @override
  bool shouldRepaint(AppleStyleAvatarPainter oldDelegate) {
    return oldDelegate.avatarData != avatarData ||
           oldDelegate.clothingItem != clothingItem ||
           oldDelegate.rotationY != rotationY ||
           oldDelegate.rotationX != rotationX ||
           oldDelegate.breathingScale != breathingScale ||
           oldDelegate.eyeOpenness != eyeOpenness;
  }
}

