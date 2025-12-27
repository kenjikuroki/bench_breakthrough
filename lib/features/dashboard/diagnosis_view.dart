import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:bench_breakthrough/l10n/generated/app_localizations.dart';

class DiagnosisView extends StatelessWidget {
  const DiagnosisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 48),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.diagnosisTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Coming Soon...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
