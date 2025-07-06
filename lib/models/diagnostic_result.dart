class DiagnosticResult {
  String url;
  String desc;
  String timestamp;

  DiagnosticResult({
    this.url = '',
    this.desc = '',
    this.timestamp = '',
  });

  factory DiagnosticResult.fromMap(data) {
    return DiagnosticResult(
      url: data['url'] ?? '',
      desc: data['desc'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'desc': desc,
      'timestamp': timestamp,
    };
  }
}