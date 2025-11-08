import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8FB), // Very light pink
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFF3E5F5), // Very light purple
              Color(0xFFE8EAF6), // Light lavender
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1BEE7).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8BBD0).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1C4E9).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Double Circle Logo with Ameya
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer big circle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFBA68C8), // Medium purple
                                Color(0xFF9575CD), // Light purple
                                Color(0xFF7986CB), // Lavender blue
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9575CD).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                        ),
                        
                        // Inner small circle
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFF8FB),
                                Color(0xFFFCE4EC),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 20,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _buildHandwrittenTextWithFallbacks(),
                          ),
                        ),
                        
                        // Decorative elements on outer circle
                        Positioned(
                          top: 25,
                          right: 30,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 5,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 35,
                          left: 25,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 5,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 35,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8BBD0).withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Tagline with beautiful style
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF3E5F5),
                            Color(0xFFE8EAF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9575CD).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 15,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Boundless ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7E57C2),
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: 'Careness',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFBA68C8),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Elegant Loading Indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1BEE7).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 5,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 3),
                          curve: Curves.easeInOut,
                          width: 140 * _controller.value,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFBA68C8),
                                Color(0xFF9575CD),
                                Color(0xFF7986CB),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9575CD).withOpacity(0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Subtle decorative dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedDot(0),
                        _buildAnimatedDot(1),
                        _buildAnimatedDot(2),
                        _buildAnimatedDot(3),
                        _buildAnimatedDot(4),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Professional text with signature style
                    Text(
                      'Premium Healthcare Experience',
                      style: GoogleFonts.dancingScript(
                        color: const Color(0xFF7986CB),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
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

  Widget _buildHandwrittenTextWithFallbacks() {
    // Simple approach - try fonts directly and handle errors gracefully
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            // Try Dancing Script first, fallback to others
            _buildTextWithFont('Dancing Script', true),
            _buildTextWithFont('Dancing Script', false),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFBA68C8),
                Color(0xFF9575CD),
                Color(0xFF7986CB),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9575CD).withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextWithFont(String fontFamily, bool isShadow) {
    try {
      TextStyle textStyle;
      
      switch (fontFamily) {
        case 'Dancing Script':
          textStyle = GoogleFonts.dancingScript(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: isShadow 
                ? const Color(0xFF7E57C2).withOpacity(0.3)
                : const Color(0xFF7E57C2),
            letterSpacing: 1.5,
            shadows: isShadow ? null : [
              Shadow(
                blurRadius: 10,
                color: const Color(0xFF9575CD).withOpacity(0.4),
                offset: const Offset(3, 3),
              ),
            ],
          );
          break;
        case 'Great Vibes':
          textStyle = GoogleFonts.greatVibes(
            fontSize: 38,
            fontWeight: FontWeight.w400,
            color: isShadow 
                ? const Color(0xFF7E57C2).withOpacity(0.3)
                : const Color(0xFF7E57C2),
            letterSpacing: 1.5,
            shadows: isShadow ? null : [
              Shadow(
                blurRadius: 10,
                color: const Color(0xFF9575CD).withOpacity(0.4),
                offset: const Offset(3, 3),
              ),
            ],
          );
          break;
        default:
          textStyle = TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: isShadow 
                ? const Color(0xFF7E57C2).withOpacity(0.3)
                : const Color(0xFF7E57C2),
            letterSpacing: 2,
            shadows: isShadow ? null : [
              Shadow(
                blurRadius: 10,
                color: const Color(0xFF9575CD).withOpacity(0.4),
                offset: const Offset(3, 3),
              ),
            ],
          );
      }
      
      return Text(
        'Ameya',
        style: textStyle,
      );
    } catch (e) {
      // Fallback to default text style
      return Text(
        'Ameya',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          color: isShadow 
              ? const Color(0xFF7E57C2).withOpacity(0.3)
              : const Color(0xFF7E57C2),
          letterSpacing: 2,
          shadows: isShadow ? null : [
            Shadow(
              blurRadius: 10,
              color: const Color(0xFF9575CD).withOpacity(0.4),
              offset: const Offset(3, 3),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + (index * 200)),
      curve: Curves.easeInOut,
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: [
          const Color(0xFFF8BBD0),
          const Color(0xFFE1BEE7),
          const Color(0xFFBA68C8),
          const Color(0xFF9575CD),
          const Color(0xFF7986CB),
        ][index],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 3,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: const Color(0xFF9575CD).withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}