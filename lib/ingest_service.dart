class PresignedUrl {
  final String uploadUrl;
  PresignedUrl({required this.uploadUrl});
}

class IngestService {
  Future<PresignedUrl> requestPresignedUrl() async {
    return PresignedUrl(uploadUrl: '');
  }

  Future<bool> uploadToPresigned(String url, dynamic bytes) async {
    return true;
  }

  Future<Map<String, dynamic>> sendIngest(dynamic payload) async {
    return {};
  }
}
