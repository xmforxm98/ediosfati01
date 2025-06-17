import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/random_login_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _message;
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _handleResetPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _message = "Please enter your email address.";
        _isLoading = false;
        _isSuccess = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message =
            "Password reset email has been sent to ${_emailController.text}. Please check your inbox and follow the instructions.";
        _isSuccess = true;
      });
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email address.";
          break;
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;
        case 'network-request-failed':
          message = "Please check your network connection and try again.";
          break;
        default:
          message = "Failed to send reset email. Please try again.";
      }
      setState(() {
        _message = message;
        _isSuccess = false;
      });
    } catch (e) {
      setState(() {
        _message = "An unexpected error occurred. Please try again.";
        _isSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RandomLoginBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.withAlpha(128)
                          : Colors.red.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSuccess ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _isSuccess ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0f3460),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Send Reset Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                if (_isSuccess) ...[
                  CustomButton(
                    text: 'Back to Login',
                    onPressed: () => Navigator.of(context).pop(),
                    isOutlined: true,
                    textColor: Colors.white,
                  ),
                ] else ...[
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
