import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class CertificatePinning {
  static Future<void> init() async {
    // TODO: Replace with your server's SHA256 hash
    final allowedSHAFingerprints = [
      'your_sha256_hash_here',
    ];

    await HttpCertificatePinning.check(
      serverURL: 'your_backend_api_url_here', // TODO: Replace with your backend API URL
      headerHttp: {
        'Content-Type': 'application/json',
      },
      sha: SHA.SHA256,
      allowedSHAFingerprints: allowedSHAFingerprints,
      timeout: 50,
    );
  }
}
