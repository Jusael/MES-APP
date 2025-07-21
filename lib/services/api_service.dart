import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.10:5999';
 // static const String baseUrl = 'http://localhost:5216';
  //GET은 데이터 조회만.
  //화면에서 사용할때 예시
  //final response = await ApiService.get('/api/user/info');

  static Future<http.Response> get(
      String path, {
        Map<String, String>? headers,
        Map<String, String>? queryParams,
      }) async {
    try {
      final uri = Uri.parse(baseUrl + path).replace(queryParameters: queryParams);
      return await http.get(uri, headers: headers ?? {});
    } catch (e) {
      throw Exception('GET 실패: $e');
    }
  }


  //POST는 API통신으로 값을 받아온다.
  //화면에서 사용할때 예시
  //헤더(headers) 요청에 대한 "정보"를 담는 곳
  // 즉, "이 요청은 어떤 형식으로 되어 있고, 누가 보냈고, 어떻게 처리해줘야 해!"라고 서버에 알려주는 메타데이터.
  //바디(body) 실제 데이터를 담는 곳
  //final response = await ApiService.post('/api/user/login',{'userId': 'test01','password': '1234',},);
  static Future<http.Response> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');

      final defaultHeaders = {'Content-Type': 'application/json'};

      return await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(data),
      );
    } catch (e) {
      throw Exception('$e');
    }
  }

  // put은 수정요청
  //화면에서 사용할때 예시
  //final response = await ApiService.put('/api/user/login',{'userId': 'test01','password': '1234',},);
  static Future<http.Response> put(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final defaultHeaders = {'Content-Type': 'application/json', ...?headers};

      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception(
          'PUT 실패: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('PUT 예외: $e');
    }
  }
}
