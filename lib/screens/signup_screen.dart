import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'success_screen.dart'; // Import for navigation

// Signup Screen w/ Interactive Form
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const String _strongPasswordBadgeUrl =
      'https://as1.ftcdn.net/jpg/01/34/82/50/1000_F_134825089_U2L05tV3bdBMVsHMVsj3qk6N4aQDdLDx.jpg';
  static const String _earlyBirdBadgeUrl =
      'https://thumbs.dreamstime.com/z/early-bird-discount-vector-special-offer-sale-icon-early-bird-icon-cartoon-promo-sign-banner-early-bird-discount-vector-special-167520195.jpg?ct=jpeg';
  static const String _profileCompleterBadgeUrl =
      'https://media.tenor.com/fBoHGC2NMOIAAAAe/deepfried-blobfry-deepfry.png';
  static const List<_Milestone> _progressMilestones = [
    _Milestone(
      threshold: 0.25,
      message: 'Fantastic start! 25% complete.',
      icon: Icons.flag,
      color: Color(0xFF9575CD),
    ),
    _Milestone(
      threshold: 0.5,
      message: 'Halfway hero! Keep the momentum.',
      icon: Icons.auto_awesome,
      color: Color(0xFF4FC3F7),
    ),
    _Milestone(
      threshold: 0.75,
      message: 'So close! Just a few taps left.',
      icon: Icons.emoji_events,
      color: Color(0xFFFFB74D),
    ),
    _Milestone(
      threshold: 1.0,
      message: 'Adventure ready! Everything is complete.',
      icon: Icons.rocket_launch,
      color: Color(0xFF81C784),
    ),
  ];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final List<_AvatarOption> _avatars = const [
    _AvatarOption(emoji: '🧙‍♂️', label: 'Wizard', color: Color(0xFF9575CD)),
    _AvatarOption(emoji: '🧝‍♀️', label: 'Elf', color: Color(0xFF4FC3F7)),
    _AvatarOption(emoji: '🛡️', label: 'Guardian', color: Color(0xFFFFB74D)),
    _AvatarOption(emoji: '🐉', label: 'Dragon', color: Color(0xFFA5D6A7)),
    _AvatarOption(emoji: '🤖', label: 'Robot', color: Color(0xFFE57373)),
  ];
  _AvatarOption? _selectedAvatar;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = 'Start typing to test your password power';
  double _completionProgress = 0;
  double _previousProgress = 0;
  String _progressMessage = 'Begin your quest by completing the fields!';
  IconData _progressIcon = Icons.map;
  Color _progressAccentColor = const Color(0xFF7E57C2);
  bool _showMilestoneCelebration = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isDobValid = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _dobController.addListener(_updateProgress);
    _updateProgress();
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateProgress);
    _emailController.removeListener(_updateProgress);
    _dobController.removeListener(_updateProgress);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      _updateProgress();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAvatar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose an avatar to complete your adventure profile!'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return; // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              avatarEmoji: _selectedAvatar!.emoji,
              avatarColor: _selectedAvatar!.color,
              badges: _determineBadges(),
            ),
          ),
        );
      });
    }
  }

  void _updatePasswordStrength(String password) {
    double strength = 0;
    if (password.isNotEmpty) {
      if (password.length >= 6) strength += 0.3;
      if (password.length >= 10) strength += 0.2;
      if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
      if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
        strength += 0.25;
      }
    }
    strength = strength.clamp(0, 1);

    String label;
    if (strength == 0) {
      label = 'Start typing to test your password power';
    } else if (strength < 0.4) {
      label = 'Needs more magic';
    } else if (strength < 0.7) {
      label = 'Getting stronger';
    } else if (strength < 0.9) {
      label = 'Almost unbreakable';
    } else {
      label = 'Legendary!';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
    _updateProgress();
  }

  Color _passwordStrengthColor() {
    return Color.lerp(Colors.red, Colors.green, _passwordStrength) ??
        Colors.red;
  }

  void _updateProgress() {
    final bool nameComplete = _nameController.text.trim().isNotEmpty;
    final bool emailComplete = _emailController.text.trim().isNotEmpty;
    final bool dobComplete = _dobController.text.trim().isNotEmpty;
    final bool passwordComplete = _passwordController.text.trim().isNotEmpty;
    final bool avatarComplete = _selectedAvatar != null;

    final int completedSteps = [
      nameComplete,
      emailComplete,
      dobComplete,
      passwordComplete,
      avatarComplete,
    ].where((step) => step).length;

    const int totalSteps = 5;
    final double newProgress =
        totalSteps == 0 ? 0 : completedSteps / totalSteps;

    _Milestone? unlockedMilestone;
    for (final milestone in _progressMilestones) {
      if (_previousProgress < milestone.threshold &&
          newProgress >= milestone.threshold) {
        unlockedMilestone = milestone;
        break;
      }
    }

    String progressMessage = 'Begin your quest by completing the fields!';
    IconData progressIcon = Icons.map;
    Color progressColor = const Color(0xFF7E57C2);

    for (final milestone in _progressMilestones) {
      if (newProgress >= milestone.threshold) {
        progressMessage = milestone.message;
        progressIcon = milestone.icon;
        progressColor = milestone.color;
      } else {
        break;
      }
    }

    if (unlockedMilestone != null) {
      _triggerMilestoneCelebration();
    }

    setState(() {
      _completionProgress = newProgress;
      _progressMessage = progressMessage;
      _progressIcon = progressIcon;
      _progressAccentColor = progressColor;
      _previousProgress = newProgress;
      _isNameValid = nameComplete;
      _isEmailValid = emailComplete && _isValidEmailFormat(_emailController.text.trim());
      _isPasswordValid = _passwordController.text.trim().length >= 6;
      _isDobValid = dobComplete;
      if (unlockedMilestone != null) {
        _showMilestoneCelebration = true;
      }
    });

    if (unlockedMilestone != null) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _showMilestoneCelebration = false;
        });
      });
    }
  }

  Future<void> _triggerMilestoneCelebration() async {
    HapticFeedback.mediumImpact();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('sounds/successchime.mp3'),
      );
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  List<AchievementBadge> _determineBadges() {
    final List<AchievementBadge> badges = [];
    final DateTime now = DateTime.now();

    if (_passwordStrength >= 0.7) {
      badges.add(const AchievementBadge(
        title: 'Strong Password Master',
        description: 'You forged a legendary password!',
        imageUrl: _strongPasswordBadgeUrl,
      ));
    }

    if (now.hour < 12) {
      badges.add(const AchievementBadge(
        title: 'The Early Bird Special',
        description: 'Registered before noon like a pro.',
        imageUrl: _earlyBirdBadgeUrl,
      ));
    }

    if (_allFieldsCompleted()) {
      badges.add(const AchievementBadge(
        title: 'Profile Completer',
        description: 'Every field filled. No detail left behind!',
        imageUrl: _profileCompleterBadgeUrl,
      ));
    }

    return badges;
  }

  bool _allFieldsCompleted() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _selectedAvatar != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Animated Form Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Adventure Progress Tracker
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Adventure Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(_completionProgress * 100).round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _progressAccentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _completionProgress,
                          minHeight: 12,
                          backgroundColor: Colors.deepPurple[50],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressAccentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Container(
                          key: ValueKey<String>(_progressMessage),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _progressAccentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              AnimatedScale(
                                scale: _showMilestoneCelebration ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  _progressIcon,
                                  color: _progressAccentColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _progressMessage,
                                  style: TextStyle(
                                    color: _progressAccentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose Your Avatar',
                    style: TextStyle(
                      color: Colors.deepPurple[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _avatars.map((avatar) {
                    final bool isSelected = _selectedAvatar == avatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                        _updateProgress();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.deepPurple.shade100,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: isSelected
                                  ? Colors.white
                                  : avatar.color.withValues(alpha: 0.25),
                              child: Text(
                                avatar.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              avatar.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.deepPurple[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                  isValid: _isNameValid,
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                  isValid: _isEmailValid,
                ),
                const SizedBox(height: 20),

                // DOB w/Calendar
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    suffixIconConstraints:
                        const BoxConstraints(minHeight: 0, minWidth: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _buildValidationSlot(_isDobValid),
                        ),
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _selectDate,
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Pswd Field w/ Toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: _updatePasswordStrength,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.deepPurple),
                    suffixIconConstraints:
                        const BoxConstraints(minHeight: 0, minWidth: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _buildValidationSlot(_isPasswordValid),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.deepPurple[50],
                          color: _passwordStrengthColor(),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _passwordStrengthLabel,
                        style: TextStyle(
                          color: _passwordStrengthColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button w/ Loading Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isValid,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildValidationSlot(isValid),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildValidationSlot(bool isValid) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: child,
        ),
        child: isValid
            ? const Icon(
                Icons.check_circle,
                key: ValueKey('valid'),
                color: Colors.green,
                size: 22,
              )
            : const SizedBox(
                key: ValueKey('invalid'),
              ),
      ),
    );
  }

  bool _isValidEmailFormat(String email) {
    if (email.isEmpty) return false;
    return email.contains('@') && email.contains('.');
  }
}

class _AvatarOption {
  final String emoji;
  final String label;
  final Color color;

  const _AvatarOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class _Milestone {
  final double threshold;
  final String message;
  final IconData icon;
  final Color color;

  const _Milestone({
    required this.threshold,
    required this.message,
    required this.icon,
    required this.color,
  });
}
