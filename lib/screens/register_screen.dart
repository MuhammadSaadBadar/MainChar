import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          const _GrainOverlay(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const _Header(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 900) {
                              return _DesktopLayout(
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController,
                                isLoading: _isLoading,
                                onRegister: _handleRegister,
                              );
                            } else {
                              return _MobileLayout(
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController,
                                isLoading: _isLoading,
                                onRegister: _handleRegister,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _Footer()),
              ],
            ),
          ),
          // Mobile Bottom Nav
          if (MediaQuery.of(context).size.width < 900) const _MobileBottomNav(),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (!email.toLowerCase().endsWith('@cuilahore.edu.pk')) {
      Get.snackbar(
        'Error',
        'Only @cuilahore.edu.pk emails are allowed',
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (response.user != null) {
        Get.defaultDialog(
          title: 'Verification Sent',
          middleText:
              'Please check your email at $email to verify your account.',
          backgroundColor: AppColors.surfaceContainerHigh,
          titleStyle: AppTextStyles.headline(20),
          middleTextStyle: AppTextStyles.body(16),
          confirm: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Go to Login'),
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ).withBlur(120),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.08),
            ),
          ).withBlur(120),
        ),
      ],
    );
  }
}

extension _BlurExtension on Widget {
  Widget withBlur(double sigma) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    child: this,
  );
}

class _GrainOverlay extends StatelessWidget {
  const _GrainOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAT_w_ZeV94lSMmj6dQo2D_WDwLvvvFmQzKj7frQuQoMpliedmi0sooCJZUPkZCMJVLdzhig9_Buf2LETpdc7fClZ8Gj5iadPNSWLsOZQF5rnDALFW0hXiKc8EmxRNU0BsM9fWqmkKS75PxkfyZfZVnw0nxoysOHLkqUEec_9dXUKNu_sTJrE1A-ndyzf_36PQkS-eZkesf1KLP0GiXh9m525ZmPtlCOMTniwXxndxDmBnLcadAC59OYpo1czOWZGzo0YM0eKyseio',
              ),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.black.withOpacity(0.6),
      floating: true,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CAMPUS VIBE',
              style: AppTextStyles.headline(
                24,
                color: AppColors.secondary,
                italic: true,
              ),
            ),
            if (MediaQuery.of(context).size.width > 768)
              Row(
                children: [
                  _HeaderLink(label: 'Register', active: true, onTap: () {}),
                  const SizedBox(width: 32),
                  _HeaderLink(
                    label: 'Login',
                    onTap: () => Get.toNamed(AppRoutes.LOGIN),
                  ),
                ],
              ),
            const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.white10, height: 0.5),
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _HeaderLink({
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              12,
              color: active ? AppColors.secondary : AppColors.onSurfaceVariant,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: AppColors.secondary,
            ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;

  const _MobileLayout({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _EditorialContent(),
        const SizedBox(height: 48),
        _FormCard(
          usernameController: usernameController,
          emailController: emailController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          isLoading: isLoading,
          onRegister: onRegister,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;

  const _DesktopLayout({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 5, child: _EditorialContent()),
        const SizedBox(width: 48),
        Expanded(
          flex: 7,
          child: _FormCard(
            usernameController: usernameController,
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            isLoading: isLoading,
            onRegister: onRegister,
          ),
        ),
      ],
    );
  }
}

class _EditorialContent extends StatelessWidget {
  const _EditorialContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'PHASE 01: ENTRY',
            style: AppTextStyles.label(
              10,
              color: AppColors.primary,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: AppTextStyles.headline(
              MediaQuery.of(context).size.width > 600 ? 64 : 48,
            ),
            children: [
              const TextSpan(text: 'Join the \n'),
              TextSpan(
                text: 'Campus Elite',
                style: AppTextStyles.headline(
                  MediaQuery.of(context).size.width > 600 ? 64 : 48,
                  color: AppColors.secondary,
                  italic: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'The only platform verified for your university. Connect, vote, and dominate your campus social scene.',
          style: AppTextStyles.body(18, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 48),
        const Row(
          children: [
            Expanded(
              child: _StatCard(value: '10,000+', label: 'Students Active'),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                value: '50+',
                label: 'Verified Hubs',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const _SocialProofAvatars(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.headline(32, color: color)),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(
              10,
              letterSpacing: 1.5,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialProofAvatars extends StatelessWidget {
  const _SocialProofAvatars();

  @override
  Widget build(BuildContext context) {
    final avatars = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmqQA5SsZLwR6_moht9xBQPVuNS_-Dg2N3wAAEnvqHnD3m3t0C2tkfIbjtn5kiN2Ix8en9Il3jg4F9V06wX3VdfNQcJOgIDR5AiYS1Wxim49sd7h3N51y9P5DcrSSf1rbfD1z3eJUgbelbjf1LWPaYsMmosDwvw3-xCVX3FLy_H3JfEF2hvveGWTJgqX9eZfN4LBRsFYW_u9OVdfxrpe67BDgtrP_c0AqTZ_awAD0x0rQbi1e7W3iE_9DONTHtuVBZO4A_0PddBL4',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDKEi8RqKptMwqe1cKfqgUTvjyWAdaeEGU-g1ft8cLMiCUly6r3kFaM21GykDFddGry8OGODNfY3F6RWXTisNW6J155aigpXzpzhVbiaJbFPWDlektj_c6yOpKep2bdh9K47TDSIsjO_s8aTjOuprEABbTpZEDLJoK6Bjokmu1QOYRJskOEPO4XXFgITC19ocaaxXpX7FAXoqYw19XBM44YnYkKma3jCKdWD9qeGuzQukaTcckl2o-_5F_HIpxeQNO9L6gfoDmccf4',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBVvzD0coY5HMwlxsIs85hLWEdH3nrrLFC6SEjNnTRCGYPUYT0j7KFhYfcsN-58onXZ3pEVGSGqG23nsVZgp7qJLjqkQRBiMsbQwTw9qEcCUkeK5RSwGPJRHb4rsdSP4q0-Ss_gl4uaV5zWbH4j-LwzDJ0uEoLdF2QF7OuyZ6zMq0_aJxoEiuFdU6gSvjRIX8Xae8K3tgZrlBudE9gzcG_zbaAa4Q8BKyCkATO4rWQ7fsrDMmJRQxsdoAmRriTvNPwwgVQs32kqATk',
    ];

    return Row(
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: avatars.length + 1,
            itemBuilder: (context, index) {
              if (index < avatars.length) {
                return Align(
                  widthFactor: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(avatars[index]),
                    ),
                  ),
                );
              } else {
                return Align(
                  widthFactor: 0.6,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '+9k',
                        style: AppTextStyles.label(
                          10,
                          color: AppColors.secondary,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Text('Ready to see who\'s around?', style: AppTextStyles.label(12)),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;

  const _FormCard({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepCounter(),
                  const SizedBox(height: 48),
                  Text(
                    'Create your identity',
                    style: AppTextStyles.headline(32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the verified campus network and claim your username.',
                    style: AppTextStyles.body(
                      14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _InputField(
                    label: 'USERNAME',
                    hint: 'vibe_master',
                    controller: usernameController,
                    icon: Icons.alternate_email_rounded,
                  ),
                  const SizedBox(height: 32),
                  _InputField(
                    label: 'UNIVERSITY EMAIL',
                    hint: 'name@cuilahore.edu.pk',
                    controller: emailController,
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(height: 32),
                  _InputField(
                    label: 'PASSWORD',
                    hint: '••••••••',
                    controller: passwordController,
                    icon: Icons.lock_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  _InputField(
                    label: 'CONFIRM PASSWORD',
                    hint: '••••••••',
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 38),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 20,
                        shadowColor: AppColors.secondary.withOpacity(0.3),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SEND VERIFICATION LINK',
                                  style: AppTextStyles.headline(
                                    16,
                                    color: Colors.black,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  weight: 900,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.label(
                          10,
                          letterSpacing: 1.0,
                          weight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(
                            text: 'BY PROCEEDING, YOU AGREE TO OUR ',
                          ),
                          TextSpan(
                            text: 'VIBE TERMS',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          const TextSpan(text: ' & '),
                          TextSpan(
                            text: 'PRIVACY CODE',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Opacity(
          opacity: 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'NEXT UP: STYLE YOUR PROFILE',
                  style: AppTextStyles.label(
                    10,
                    letterSpacing: 1.5,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepCounter extends StatelessWidget {
  const _StepCounter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 1 OF 2',
              style: AppTextStyles.label(
                10,
                color: AppColors.secondary,
                letterSpacing: 2.0,
                weight: FontWeight.bold,
              ),
            ),
            Text(
              '50% COMPLETE',
              style: AppTextStyles.label(
                10,
                letterSpacing: 2.0,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label(
            10,
            letterSpacing: 2.0,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body(16, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
            prefixIcon: Icon(widget.icon, color: AppColors.outline),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.outline,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
          style: AppTextStyles.body(16),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(vertical: 64),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Column(
        children: [
          Text(
            'CAMPUS VIBE',
            style: AppTextStyles.headline(24, color: AppColors.secondary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(label: 'Support', onTap: () {}),
              const SizedBox(width: 32),
              _FooterLink(label: 'Privacy', onTap: () {}),
              const SizedBox(width: 32),
              _FooterLink(label: 'Terms', onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, width: 80, color: AppColors.surfaceContainer),
          const SizedBox(height: 24),
          Text(
            '© 2024 MAIN CHARACTER ENERGY. .EDU VERIFIED.',
            style: AppTextStyles.label(
              10,
              letterSpacing: 2.0,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 64), // Space for mobile nav
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label(
          12,
          letterSpacing: 2.0,
          weight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(icon: Icons.bolt_rounded, label: 'QUICK VOTE'),
                  _NavIcon(icon: Icons.search_rounded, label: 'SEARCH'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.label(
            8,
            letterSpacing: 1.5,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
