import 'package:http/http.dart';
import 'package:osvitka/client.dart';
import 'package:test/test.dart';


void main() {
  group("HTTP Requests", () {
    test("GET", () async {
      var client = OsvitkaClient("192.168.4.1");
      var status = await client.getStatus();

      expect(status.status, "off");
      print(status.status);
    });
    test("PUT", () async {
      var client = OsvitkaClient("192.168.4.1");
      var newStatus = const OsvitkaStatus(exposureTime: 120, power: 65535, status: "on");
      var status = await client.setStatus(newStatus);

      expect(status.status, "on");
      print(status.power);
      print(status.exposureTime);
      print(status.status);
    });
  });
}