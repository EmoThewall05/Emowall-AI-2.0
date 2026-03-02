class PresignedUrl {
  final String uploadUrl;
  final String accessUrl;
  PresignedUrl({required this.uploadUrl, required this.accessUrl});
}

class IngestResponse {
  final int statusCode;
  IngestResponse({required this.statusCode});
}

class IngestService {
  Future<PresignedUrl> requestPresignedUrl() async {
    return PresignedUrl(uploadUrl: '', accessUrl: '');
  }

  Future<bool> uploadToPresigned(String url, dynamic bytes) async {
    return true;
  }

  Future<IngestResponse> sendIngest(dynamic payload) async {
    return IngestResponse(statusCode: 200);
  }
}
