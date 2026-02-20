import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x66122438),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x90FFFFFF), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 44, color: Colors.white),
          const SizedBox(height: 14),
          Text(
            l10n.emptyStateTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyStateDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }
}
