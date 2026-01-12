import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'settings_provider.dart';
import '../subscription/purchase_service.dart';

import 'package:bench_breakthrough/features/settings/policy_screen.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildSectionHeader(AppLocalizations.of(context)!.membership.toUpperCase()),
              _buildMembershipSection(context, ref),
              
              const Divider(color: Colors.white24, height: 40),

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
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => PolicyScreen(
                        fileName: 'privacy.md', 
                        title: AppLocalizations.of(context)!.privacyPolicy
                      ),
                    ),
                  );
                },
              ),
               ListTile(
                title: Text(AppLocalizations.of(context)!.termsOfService, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                 onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => PolicyScreen(
                        fileName: 'terms.md', 
                        title: AppLocalizations.of(context)!.termsOfService
                      ),
                    ),
                  );
                },
              ),
               ListTile(
                title: Text(AppLocalizations.of(context)!.appVersion, style: const TextStyle(color: Colors.white)),
                trailing: const Text('1.0.9', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipSection(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          title: Text(l10n.membership, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            isPremium ? l10n.proMember : l10n.freePlan,
            style: TextStyle(
              color: isPremium ? AppColors.accent : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: isPremium 
              ? const Icon(Icons.check_circle, color: AppColors.accent)
              : ElevatedButton(
                  onPressed: () {
                    ref.read(purchaseServiceProvider.notifier).buyPremium();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(l10n.upgrade),
                ),
        ),
        if (!isPremium)
          ListTile(
            title: Text(l10n.restorePurchases, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.refresh, color: Colors.grey),
            onTap: () {
              ref.read(purchaseServiceProvider.notifier).restore();
            },
          ),
      ],
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
