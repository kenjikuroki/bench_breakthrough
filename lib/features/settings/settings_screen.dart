import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // isLbsProviderを監視 (デフォルトがfalseなのでloading中でもfalse扱い等のケアが必要だが、初期値kgで問題ない)
    final isLbs = ref.watch(isLbsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(AppLocalizations.of(context)!.settings.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader(AppLocalizations.of(context)!.general.toUpperCase()),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.usePounds, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              isLbs ? 'Target: 225 lbs' : 'Target: 100 kg', 
              style: const TextStyle(color: Colors.grey)
            ),
            value: isLbs,
            activeColor: AppColors.accent,
            inactiveTrackColor: Colors.grey[800],
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleUnit();
            },
          ),
          
          const Divider(color: Colors.white24, height: 40),

          _buildSectionHeader(AppLocalizations.of(context)!.about.toUpperCase()),
           ListTile(
            title: Text(AppLocalizations.of(context)!.privacyPolicy, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Open URL
            },
          ),
           ListTile(
            title: Text(AppLocalizations.of(context)!.termsOfService, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
             onTap: () {
              // TODO: Open URL
            },
          ),
           ListTile(
            title: Text(AppLocalizations.of(context)!.appVersion, style: const TextStyle(color: Colors.white)),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}
