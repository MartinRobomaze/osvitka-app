import 'dart:convert';

import 'package:http/http.dart' as http;

class OsvitkaStatus {
  final int exposureTime;
  final int power;
  final String status;

  const OsvitkaStatus({
    required this.exposureTime,
    required this.power,
    required this.status,
  });

  factory OsvitkaStatus.fromJson(Map<String, dynamic> json) {
    return OsvitkaStatus(
        exposureTime: json['exposureTime'] == "" ? json['exposureTime'] : 0,
        power: json['power'] == "" ? json['power'] : 0,
        status: json['status']
    );
  }
}

class OsvitkaClient {
  String url;

  OsvitkaClient(this.url);

  Future<OsvitkaStatus> setStatus(OsvitkaStatus status) async {
    var statusJson = json.encode(status);
    final resp = await http.post(Uri.http(url, 'status'),
        headers: {"Content-Type": "application/json"},
        body: statusJson,
    );

    if (resp.statusCode == 200) {
      return OsvitkaStatus.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception("Failed to set LED status");
    }
  }

  Future<OsvitkaStatus> getStatus() async {
    final resp = await http.get(Uri.http(url, 'status'));

    if (resp.statusCode == 200) {
      return OsvitkaStatus.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception("Failed to set LED status");
    }
  }
}