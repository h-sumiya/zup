import 'package:flutter/material.dart';
import 'package:zup/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/managed_app.dart';
import '../utils/date_time_format.dart';
import 'app_avatar.dart';

class SimpleAppTile extends StatelessWidget {
  const SimpleAppTile({
    super.key,
    required this.app,
    required this.busy,
    required this.onTap,
  });

  final ManagedApp app;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final version = app.installedVersion ?? l10n.commonNotInstalled;

    return Material(
      color: const Color(0x7F102640),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x80FFFFFF)),
          ),
          child: Row(
            children: [
              AppAvatar(iconPath: app.iconPath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFE3BF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.commonByOwner(app.owner),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            version,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFB8FFE9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (busy) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTimeLocal(app.updatedAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
