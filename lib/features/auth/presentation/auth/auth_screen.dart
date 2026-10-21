import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/debug/build_info.dart';
import '../../../../core/widgets/tunisia_phone_field.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import '../../../../core/providers/localization_provider.dart';
import '../forgot_password/forgot_password_screen.dart';
import 'auth_controller.dart';

/// Sign in / sign up, over the moving gradient:
///   _GradientBackground, _FloatingCircles
///   _LanguageButton   (top right)
///   _LogoHeader       logo, app name, welcome line
///   _AuthCard         tabs, form, "ou", Google
///   build label       (debug builds only)
///
/// UI only: loading, show/hide, the e-mail and Google sign-in and the
/// language cycle live in [AuthScreenController]. This
/// screen keeps the tabs, the animations, the messages and the navigation.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  /// This screen's own controller (see [authScreenControllerProvider]).
  late final _provider = authScreenControllerProvider(Object());

  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _backgroundAnimationController,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _backgroundAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Un message par-dessus l'ecran, toujours visible.
  ///
  /// Les erreurs peintes sous un champ passent inapercues quand le clavier
  /// couvre le bas du formulaire.
  void _showAuthMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    // Le SEUL chemin muet de tout l'ecran etait ce `return` : pas de message,
    // pas de roue, rien. `validate()` peint bien une erreur sous le champ
    // fautif, mais ce champ peut etre hors ecran quand le clavier est ouvert,
    // et le bouton passe alors pour mort. Un message par-dessus dit au moins
    // qu'il y a quelque chose a corriger.
    if (!_formKey.currentState!.validate()) {
      _showAuthMessage('Vérifiez les champs du formulaire');
      return;
    }

    try {
      final outcome = await ref.read(_provider.notifier).submitEmail(
            isSignIn: _tabController.index == 0,
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            phone: TunisiaPhoneField.normalize(_phoneController),
          );

      if (outcome == EmailAuthOutcome.needsEmailConfirmation) {
        if (mounted) {
          _tabController.animateTo(0);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Compte créé ! Ouvrez l'email de confirmation que nous "
                "venons d'envoyer, puis connectez-vous.",
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 6),
            ),
          );
        }
        return;
      }

      // Connecte. main.dart bascule sa racine vers l'accueil tout seul ; si cet
      // ecran de connexion a ete EMPILE par-dessus (ce que faisait l'ancienne
      // deconnexion), on le ferme pour que l'accueil soit vraiment visible.
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyAuthErrorMessage(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final hasSession = await ref.read(_provider.notifier).signInWithGoogle();
      // Comme la connexion par email : ne jamais laisser un ecran de connexion
      // empile par-dessus l'accueil.
      if (mounted &&
          hasSession &&
          Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyAuthErrorMessage(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);

    return Scaffold(
      // Required (and already Flutter's default) so the body actually shrinks
      // when the keyboard opens — the fix below reacts to that shrink.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated Background with Gradient
          const _GradientBackground(),

          // Animated Decorative Elements
          _FloatingCircles(rotation: _rotationAnimation),

          // Language Switcher Button
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.02,
                  right: screenWidth * 0.05,
                ),
                child: _LanguageButton(onCycle: controller.cycleLanguage),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                top: screenHeight * 0.06, // Extra padding to avoid status bar
                bottom: screenHeight * 0.02,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // minHeight reproduces today's spaceBetween look whenever the
                  // full viewport is available. When the keyboard opens, Scaffold
                  // shrinks constraints.maxHeight; IntrinsicHeight then lets the
                  // Column grow past that height instead of overflowing, and
                  // SingleChildScrollView scrolls the rest instead of clipping it.
                  // Driven by the actual measured constraints rather than a
                  // hardcoded keyboard height, so it holds across screen sizes
                  // and both portrait/landscape.
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo and Title
                  _LogoHeader(fade: _fadeAnimation, scale: _scaleAnimation),

                  // Glassmorphic Form Container
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _AuthCard(
                        tabController: _tabController,
                        onTabChanged: () => setState(() {}),
                        formKey: _formKey,
                        nameController: _nameController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        state: state,
                        onToggleObscure: controller.toggleObscurePassword,
                        onSubmit: _handleEmailAuth,
                        onGoogle: _handleGoogleSignIn,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Etiquette de build (mode debug uniquement) : sans elle, on ne
          // sait pas si le telephone execute le correctif ou une vieille
          // installation.
          if (BuildInfo.label != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: IgnorePointer(
                child: Text(
                  BuildInfo.label!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sections ──────────────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.primaryLight,
          ],
        ),
      ),
    );
  }
}

class _FloatingCircles extends StatelessWidget {
  const _FloatingCircles({required this.rotation});

  final Animation<double> rotation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return AnimatedBuilder(
      animation: rotation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -screenHeight * 0.15,
              right: -screenWidth * 0.2 + (rotation.value * screenWidth * 0.1),
              child: Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -screenHeight * 0.1,
              left: -screenWidth * 0.15 - (rotation.value * screenWidth * 0.1),
              child: Container(
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.3,
              left: -screenWidth * 0.1,
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageButton extends ConsumerWidget {
  const _LanguageButton({required this.onCycle});

  final void Function(String currentCode) onCycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final locale = ref.watch(localizationProvider);
    return IconButton(
      onPressed: () => onCycle(locale.languageCode),
      icon: Container(
        padding: EdgeInsets.all(screenWidth * 0.025),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenHeight * 0.005),
            ),
          ],
        ),
        child: Icon(
          Icons.language_rounded,
          color: Colors.white,
          size: screenWidth * 0.06,
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.fade, required this.scale});

  final Animation<double> fade;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Column(
          children: [
            // Logo Container
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: screenWidth * 0.05,
                    offset: Offset(0, screenHeight * 0.01),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            // App Title
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontSize: screenWidth * 0.09,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),

            // Welcome Text
            Text(
              AppLocalizations.of(context)!.welcome,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The frosted card: tabs, the form of the current tab, "ou", Google.
class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.tabController,
    required this.onTabChanged,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.state,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onGoogle,
  });

  final TabController tabController;
  final VoidCallback onTabChanged;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthScreenState state;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.08),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(screenWidth * 0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: screenWidth * 0.08,
                offset: Offset(0, screenHeight * 0.015),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom Tab Bar
              _AuthTabBar(tabController: tabController, onTabChanged: onTabChanged),
              SizedBox(height: screenHeight * 0.025),

              // Form
              _AuthForm(
                isSignIn: tabController.index == 0,
                formKey: formKey,
                nameController: nameController,
                phoneController: phoneController,
                emailController: emailController,
                passwordController: passwordController,
                state: state,
                onToggleObscure: onToggleObscure,
                onSubmit: onSubmit,
              ),

              SizedBox(height: screenHeight * 0.02),

              // Divider
              const _OrDivider(),

              SizedBox(height: screenHeight * 0.02),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: onGoogle,
                    isLoading: state.isLoading,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTabBar extends StatelessWidget {
  const _AuthTabBar({required this.tabController, required this.onTabChanged});

  final TabController tabController;
  final VoidCallback onTabChanged;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return Container(
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFF7931E),
            ],
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: screenWidth * 0.03,
              offset: Offset(0, screenHeight * 0.005),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.04,
        ),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.signIn),
          Tab(text: AppLocalizations.of(context)!.signUp),
        ],
        onTap: (_) => onTabChanged(),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.isSignIn,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.state,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final bool isSignIn;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthScreenState state;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (!isSignIn) ...[
            _AuthTextField(
              controller: nameController,
              label: AppLocalizations.of(context)!.fullName,
              icon: Icons.person_outline_rounded,
            ),
            SizedBox(height: screenHeight * 0.015),
            TunisiaPhoneField(
              controller: phoneController,
              label: AppLocalizations.of(context)!.phoneNumberLabel,
              invalidMessage: AppLocalizations.of(context)!.phoneInvalid,
            ),
            SizedBox(height: screenHeight * 0.015),
          ],
          _AuthTextField(
            controller: emailController,
            label: AppLocalizations.of(context)!.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: screenHeight * 0.015),
          _AuthTextField(
            controller: passwordController,
            label: AppLocalizations.of(context)!.password,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isObscure: state.obscurePassword,
            onToggleObscure: onToggleObscure,
          ),

          // "Forgot Password?" — only on Sign In tab
          if (isSignIn)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.005,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: screenWidth * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(height: screenHeight * 0.015),

          // Main Action Button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
              ),
              child: state.isLoading
                  ? SizedBox(
                      height: screenHeight * 0.025,
                      width: screenHeight * 0.025,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      isSignIn
                          ? AppLocalizations.of(context)!.signIn
                          : AppLocalizations.of(context)!.createAccount,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.textLight.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            AppLocalizations.of(context)!.or,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isObscure,
    this.onToggleObscure,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? isObscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return TextFormField(
      controller: controller,
      obscureText: isObscure ?? false,
      keyboardType: keyboardType,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontSize: screenWidth * 0.04,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.8),
          fontSize: screenWidth * 0.038,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary.withOpacity(0.7),
          size: screenWidth * 0.06,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscure! ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: screenWidth * 0.055,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          borderSide: BorderSide(
            color: AppColors.textLight.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnter(label);
        }
        if (label == AppLocalizations.of(context)!.email && !value.contains('@')) {
          return AppLocalizations.of(context)!.validEmail;
        }
        if (label == AppLocalizations.of(context)!.password && value.length < 6) {
          return AppLocalizations.of(context)!.passwordLength;
        }
        if (label == AppLocalizations.of(context)!.phoneNumberLabel) {
          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.length < 8) return AppLocalizations.of(context)!.phoneInvalid;
        }
        return null;
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.045),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: AppColors.textLight.withOpacity(0.25),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: screenWidth * 0.02,
                offset: Offset(0, screenHeight * 0.005),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: screenWidth * 0.08,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
