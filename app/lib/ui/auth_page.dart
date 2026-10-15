import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../data/remote/api_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loginMode = true;
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      loginMode = true;
      emailC.text = 'demo@test.com';
      passC.text = 'demo123';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2FF),
              Color(0xFFF8FAFC),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(child: Text(state.error!)),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Card(
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.indigo.shade100, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Brand Header
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_rounded,
                                  size: 38,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Field Notes',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Offline-First Inspection & Tracking',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Segmented Mode Switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => loginMode = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: loginMode ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: loginMode
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.06),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          'Log in',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: loginMode ? FontWeight.bold : FontWeight.w500,
                                            color: loginMode ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => loginMode = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: !loginMode ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: !loginMode
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.06),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          'Create account',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: !loginMode ? FontWeight.bold : FontWeight.w500,
                                            color: !loginMode ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Inputs
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: loginMode
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TextField(
                                  controller: nameC,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_rounded, color: Colors.indigo.shade400),
                                  ),
                                ),
                              ),
                            ),
                            TextField(
                              controller: emailC,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.indigo.shade400),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passC,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.indigo.shade400),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                ),
                              ),
                            ),
                            if (loginMode) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showForgotPasswordModal(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF4F46E5),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),

                            // Submit Button
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: state.loading
                                    ? null
                                    : () {
                                        final email = emailC.text.trim();
                                        final pass = passC.text;
                                        if (loginMode) {
                                          context.read<AuthBloc>().add(AuthLogin(email, pass));
                                        } else {
                                          context.read<AuthBloc>().add(AuthRegister(nameC.text.trim(), email, pass));
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: state.loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        loginMode ? 'Sign In' : 'Get Started',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 1-Click Demo Credentials Pill
                            Center(
                              child: InkWell(
                                onTap: _fillDemo,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF86EFAC)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF16A34A)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Fill Demo Login (demo@test.com)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    final api = context.read<AuthBloc>().api;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => _ForgotPasswordDialog(
        api: api,
        initialEmail: emailC.text.trim(),
        onSuccess: (email, newPassword) {
          setState(() {
            loginMode = true;
            emailC.text = email;
            passC.text = newPassword;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Password reset successfully! You can now sign in.'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final ApiService api;
  final String initialEmail;
  final void Function(String email, String newPassword) onSuccess;

  const _ForgotPasswordDialog({
    required this.api,
    required this.initialEmail,
    required this.onSuccess,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  int step = 1;
  late final TextEditingController emailC;
  final otpC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  bool loading = false;
  String? error;
  String? infoBanner;
  String? previewOtp;
  bool obscurePass = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    emailC = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailC.dispose();
    otpC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = emailC.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => error = 'Please enter a valid email address');
      return;
    }
    setState(() {
      loading = true;
      error = null;
      infoBanner = null;
    });

    try {
      final res = await widget.api.forgotPassword(email);
      final preview = res['previewOtp'] as String?;
      final emailSent = res['emailSent'] == true;

      setState(() {
        loading = false;
        step = 2;
        previewOtp = preview;
        if (preview != null) {
          otpC.text = preview;
          infoBanner = 'Demo Mode: Verification code $preview generated (no SMTP configured).';
        } else if (emailSent) {
          infoBanner = 'Verification code sent to $email. Please check your inbox.';
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = emailC.text.trim();
    final otp = otpC.text.trim();
    final pass = passC.text;
    final confirm = confirmPassC.text;

    if (otp.length < 6) {
      setState(() => error = 'Please enter the complete 6-digit code');
      return;
    }
    if (pass.length < 6) {
      setState(() => error = 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await widget.api.resetPassword(email, otp, pass);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess(email, pass);
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon & Title
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      step == 1 ? Icons.lock_reset_rounded : Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step == 1 ? 'Reset Password' : 'Enter Verification Code',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          step == 1
                              ? 'Receive a 6-digit OTP to reset your password'
                              : 'Enter the code and set your new password',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Info / Demo Banner
              if (infoBanner != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          infoBanner!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Error Banner
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Step 1: Email Form
              if (step == 1) ...[
                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Registered Email',
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.indigo.shade400),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: loading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Send Verification Code',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ),
              ],

              // Step 2: OTP & New Password
              if (step == 2) ...[
                TextField(
                  controller: otpC,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                  decoration: InputDecoration(
                    labelText: '6-Digit Verification Code',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_rounded, color: Colors.indigo.shade400),
                    suffixIcon: previewOtp != null
                        ? TextButton(
                            onPressed: () => otpC.text = previewOtp!,
                            child: const Text('Auto-fill', style: TextStyle(fontSize: 11)),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passC,
                  obscureText: obscurePass,
                  decoration: InputDecoration(
                    labelText: 'New Password (min 6 chars)',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.indigo.shade400),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () => setState(() => obscurePass = !obscurePass),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassC,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_reset_rounded, color: Colors.indigo.shade400),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                step = 1;
                                error = null;
                                infoBanner = null;
                              });
                            },
                      child: const Text('Back'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: loading ? null : _sendOtp,
                      child: const Text('Resend Code'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: loading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Reset Password & Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

