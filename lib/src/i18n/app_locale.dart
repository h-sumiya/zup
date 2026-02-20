import 'package:flutter/material.dart';

const List<Locale> supportedAppLocales = <Locale>[
  Locale('ja'),
  Locale('en'),
  Locale('zh'),
];

Locale? appLocaleFromCode(String? code) {
  final normalized = normalizeAppLocaleCode(code);
  if (normalized == null) {
    return null;
  }
  return Locale(normalized);
}

String? normalizeAppLocaleCode(String? code) {
  final normalized = code?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  switch (normalized) {
    case 'ja':
    case 'en':
    case 'zh':
      return normalized;
    default:
      return null;
  }
}
