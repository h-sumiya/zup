import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.onAdd,
    required this.onRefresh,
    required this.onSettings,
    super.key,
  });

  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 900;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZUP',
          style: GoogleFonts.bebasNeue(
            fontSize: 68,
            letterSpacing: 2,
            color: const Color(0xFFFFC17A),
            height: 0.9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeSubtitle,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        IconButton.filledTonal(
          onPressed: onSettings,
          tooltip: l10n.settingsTitle,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0x22102C45),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.settings),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x80FFFFFF)),
            backgroundColor: const Color(0x22102C45),
          ),
          icon: const Icon(Icons.refresh),
          label: Text(l10n.homeReload),
        ),
        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A35),
            foregroundColor: const Color(0xFF09111E),
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.homeAddUrl),
        ),
      ],
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }
}
