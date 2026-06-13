import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../util/core_export.dart';
import 'package:path/path.dart';


class ApiClient extends GetxService {
  final String? appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    if (kDebugMode) {
      _log('API Base URL: $appBaseUrl');
    }
    token = SecureTokenStorage.cachedToken().isEmpty ? null : SecureTokenStorage.cachedToken();
    try {

    }catch(e) {
      if (kDebugMode) {
        print("");
      }
    }
    updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
  }
  void updateHeader(String? token, String? languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      AppConstants.localizationKey: languageCode ?? AppConstants.languages[0].languageCode!,

    };
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      _log('====> API Call: $uri');
      http.Response response = await http.get(
        Uri.parse(appBaseUrl!+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String? uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      _log('====> API Call: $uri');
      _log('====> API Body: $body');
      http.Response response = await http.post(
        Uri.parse(appBaseUrl!+uri!),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartDataConversation(
      String? uri,
      Map<String, String> body,
      List<MultipartBody>? multipartBody,
      {Map<String, String>? headers,List<PlatformFile>? otherFile}) async {

    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl!+uri!));
    final multipartHeaders = Map<String, String>.from(headers ?? _mainHeaders);
    multipartHeaders.remove('Content-Type');
    multipartHeaders['Accept'] = 'application/json';
    request.headers.addAll(multipartHeaders);

    if(otherFile != null ) {
      if(otherFile.isNotEmpty){
        for(PlatformFile platformFile in otherFile){
          request.files.add(http.MultipartFile('files[${otherFile.indexOf(platformFile)}]', platformFile.readStream!, platformFile.size, filename: basename(platformFile.name)));
        }
      }
    }
    if(multipartBody!=null){
      for(MultipartBody multipart in multipartBody) {
        Uint8List list = await multipart.file.readAsBytes();
        request.files.add(http.MultipartFile(
          multipart.key!, multipart.file.readAsBytes().asStream(), list.length, filename:'${DateTime.now().toString()}.png',
        ));
      }
    }
    request.fields.addAll(body);
    http.Response response = await http.Response.fromStream(await request.send());
    return handleResponse(response, uri);
  }

  Future<Response> postMultipartData(
      String? uri, Map<String, String> body,
      List<MultipartBody>? multipartBody,
      MultipartBody? logo,
      {Map<String, String>? headers,List<PlatformFile>? otherFile}) async {
    try {
      _log('====> API Call: $uri');
      _log('====> API Body: $body');
      if (logo != null) {
        _log('====> Multipart logo: ${logo.file.path}');
      }
      if (multipartBody != null) {
        for (final part in multipartBody) {
          _log('====> Multipart ${part.key}: ${part.file.path}');
        }
      }
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl!+uri!));
      final multipartHeaders = Map<String, String>.from(headers ?? _mainHeaders);
      multipartHeaders.remove('Content-Type');
      multipartHeaders['Accept'] = 'application/json';
      request.headers.addAll(multipartHeaders);

      Future<void> attachFile(String fieldName, XFile xFile) async {
        final bytes = await xFile.readAsBytes();
        final name = xFile.name.trim().isNotEmpty
            ? xFile.name
            : xFile.path.split('/').last;
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: name.isNotEmpty ? name : 'upload.jpg',
        ));
      }

      if (logo != null) {
        await attachFile(logo.key ?? 'logo', logo.file);
      }

      if (otherFile != null && otherFile.isNotEmpty) {
        for (PlatformFile platformFile in otherFile) {
          request.files.add(http.MultipartFile(
            'files[${otherFile.indexOf(platformFile)}]',
            platformFile.readStream!,
            platformFile.size,
            filename: basename(platformFile.name),
          ));
        }
      }

      if (multipartBody != null) {
        for (final multipart in multipartBody) {
          await attachFile(multipart.key ?? 'file', multipart.file);
        }
      }

      request.fields.addAll(body);

      http.Response response = await http.Response.fromStream(
        await request.send().timeout(Duration(seconds: timeoutInSeconds)),
      );

      return handleResponse(response, uri);
    } catch (e) {
      _log('====> Multipart upload failed: $e');
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String? uri, dynamic body, {Map<String, String>? headers}) async {
    try {
      _log('====> API Call: $uri\nHeader: $_mainHeaders');
      _log('====> API Body: $body');
      http.Response response = await http.put(
        Uri.parse(appBaseUrl!+uri!),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String? uri, {Map<String, String>? headers}) async {
    try {
      _log('====> API Call: $uri\nHeader: $_mainHeaders');
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl!+uri!),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String? uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    }catch(e) {
      if (kDebugMode) {
        print("");
      }
    }
    Response response0 = Response(
      body: body ?? response.body, bodyString: response.body.toString(),
      request: Request(headers: response.request!.headers, method: response.request!.method, url: response.request!.url),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(response0.statusCode != 200 && response0.body != null && response0.body is !String) {
      if(response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: errorResponse.errors![0].message);
      }else if(response0.body.toString().startsWith('{message')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      }
    }else if(response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    _log('====> API Response: [${response0.statusCode}] $uri');
    return response0;
  }
}

class MultipartBody {
  String? key;
  XFile file;

  MultipartBody(this.key, this.file);
}