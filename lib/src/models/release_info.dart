class ReleaseAssetInfo {
  const ReleaseAssetInfo({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  final String name;
  final String downloadUrl;
  final int? sizeBytes;
}

class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.publishedAt,
    required this.selectedAsset,
    required this.matchedAssetCount,
  });

  final String version;
  final DateTime? publishedAt;
  final ReleaseAssetInfo selectedAsset;
  final int matchedAssetCount;
}
