import "dart:convert";
import "dart:developer";
import "package:http/http.dart" as http;

class ApiUrls {
  static String baseUrl = "http://127.0.0.113:8000";
}

class BaseRepository {
  /// For GET request
  Future<http.Response> getHttp({
    required String api,
  }) async {
    final url = ApiUrls.baseUrl + api;
    log(url, name: 'getHttp');
    final response = await http.get(
      Uri.parse(url),
      headers:{'Content-Type': 'application/json'}
    );
    log(response.statusCode.toString());
    return response;
  }
}

class MuxRepo extends BaseRepository {
  Future streamKey() async {
    final response = await getHttp(api:'/');
    log(response.body, name: 'response registerApi');
    return json.decode(response.body);
  }

  Future getListStreams() async {
    final response = await getHttp(api: "/get");
    log(response.body, name: 'response registerApi');
    return json.decode(response.body);
  }

}
