import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';
import 'notepad_screen.dart';
import 'onboarding_screen.dart';
import 'staff_screen.dart';

// Update this once the app is live on the Play Store.
const _playStoreDemoLink =
    'https://play.google.com/store/apps/details?id=com.ridr.demo';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  String _ownerName = '';
  String _shopName = '';
  String? _profilePhotoPath;
  String? _companyPhotoPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _ownerName = prefs.getString('owner_name') ?? '';
      _shopName = prefs.getString('shop_name') ?? '';
      _profilePhotoPath = prefs.getString('profile_photo_path');
      _companyPhotoPath = prefs.getString('company_photo_path');
      _loading = false;
    });
  }

  Future<void> _pickPhoto({required bool isProfile}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        '${isProfile ? 'profile' : 'company'}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${dir.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        isProfile ? 'profile_photo_path' : 'company_photo_path', saved.path);

    if (!mounted) return;
    setState(() {
      if (isProfile) {
        _profilePhotoPath = saved.path;
      } else {
        _companyPhotoPath = saved.path;
      }
    });
  }

  Future<void> _goTo(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _shareApp() {
    SharePlus.instance.share(ShareParams(
      text: 'Check out Ridr — the easiest way to manage a bike rental '
          'business. Download it here: $_playStoreDemoLink',
    ));
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset app?'),
        content: const Text(
          'This will permanently delete every bike, rental, customer, staff '
          'member and note, and take you back to the very beginning. This '
          'cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _resetApp();
  }

  Future<void> _resetApp() async {
    await DatabaseHelper.instance.resetAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    try {
      final dir = await getApplicationDocumentsDirectory();
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {
            // Best-effort cleanup of saved photos; safe to ignore.
          }
        }
      }
    } catch (_) {
      // No documents directory to clean up.
    }

    await ThemeController.instance.setDarkMode(false);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrapping the whole body in this listener (rather than just the switch
    // row) guarantees every raw AppColors.* usage below repaints instantly
    // when dark mode toggles, even though this screen's own State doesn't
    // otherwise depend on Theme.of(context).
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDark, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    _ProfileHeader(
                      ownerName: _ownerName,
                      shopName: _shopName,
                      profilePhotoPath: _profilePhotoPath,
                      companyPhotoPath: _companyPhotoPath,
                      onTapProfilePhoto: () => _pickPhoto(isProfile: true),
                      onTapCompanyPhoto: () => _pickPhoto(isProfile: false),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _ThemeToggleTile(
                            isDark: isDark,
                            onChanged: (value) =>
                                ThemeController.instance.setDarkMode(value),
                          ),
                          _MenuTile(
                            icon: Icons.badge_outlined,
                            label: 'Staff',
                            subtitle: 'Add and manage your staff',
                            onTap: () => _goTo(const StaffScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.sticky_note_2_outlined,
                            label: 'Notepad',
                            subtitle: 'Reminders for yourself',
                            onTap: () => _goTo(const NotepadScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            subtitle: 'FAQs and contact support',
                            onTap: () => _goTo(const HelpSupportScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.info_outline_rounded,
                            label: 'About',
                            subtitle: 'A note from the founder',
                            onTap: () => _goTo(const AboutScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.share_outlined,
                            label: 'Share app',
                            subtitle: 'Tell other shop owners about Ridr',
                            onTap: _shareApp,
                          ),
                          _MenuTile(
                            icon: Icons.restart_alt_rounded,
                            label: 'Reset',
                            subtitle: 'Erase all data and start over',
                            iconColor: AppColors.danger,
                            labelColor: AppColors.danger,
                            onTap: _confirmReset,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String ownerName;
  final String shopName;
  final String? profilePhotoPath;
  final String? companyPhotoPath;
  final VoidCallback onTapProfilePhoto;
  final VoidCallback onTapCompanyPhoto;

  const _ProfileHeader({
    required this.ownerName,
    required this.shopName,
    required this.profilePhotoPath,
    required this.companyPhotoPath,
    required this.onTapProfilePhoto,
    required this.onTapCompanyPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final companyFile =
        companyPhotoPath != null ? File(companyPhotoPath!) : null;
    final profileFile =
        profilePhotoPath != null ? File(profilePhotoPath!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTapCompanyPhoto,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardMuted,
                  image: companyFile != null && companyFile.existsSync()
                      ? DecorationImage(
                          image: FileImage(companyFile), fit: BoxFit.cover)
                      : null,
                ),
                child: companyFile == null || !companyFile.existsSync()
                    ? Center(
                        child: Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.textSecondary, size: 30),
                      )
                    : const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.black45,
                            child: Icon(Icons.edit_rounded,
                                color: Colors.white, size: 15),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: -34,
              child: GestureDetector(
                onTap: onTapProfilePhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.surface,
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.cardMuted,
                        backgroundImage: profileFile != null &&
                                profileFile.existsSync()
                            ? FileImage(profileFile)
                            : null,
                        child: profileFile == null || !profileFile.existsSync()
                            ? Text(
                                ownerName.isNotEmpty
                                    ? ownerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryRed,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryRed,
                        child: Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shopName.isNotEmpty ? shopName : 'Your shop',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Managed by $ownerName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardMuted),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryRed)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primaryRed),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: labelColor ?? AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeToggleTile({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardMuted),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDark ? 'On' : 'Off',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDark,
              activeThumbColor: AppColors.primaryRed,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
