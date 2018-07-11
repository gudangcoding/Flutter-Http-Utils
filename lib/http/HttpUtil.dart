import 'dart:async';
import 'dart:convert';
import 'package:flutter_http/http/Api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpUtils {
  static const String GET = "get";
  static const String POST = "post";

  static void get(String url, Function callback,
      {Map<String, String> params,
      Map<String, String> headers,
      Function errorCallback}) async {
    if (!url.startsWith("http")) {
      url = Api.BASE_URL + url;
    }

    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        sb.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }

    await request(url, callback,
        method: GET, headers: headers, errorCallback: errorCallback);
  }

  static void post(String url, Function callback,
      {Map<String, dynamic> params,
      Map<String, String> headers,
      Function errorCallback}) async {

    if (!url.startsWith("http")) {
      url = Api.BASE_URL + url;
    }

    await request(url, callback,
        method: POST,
        headers: headers,
        params: params,
        errorCallback: errorCallback);
  }

  static Future request(String url, Function callback,
      {String method,
      Map<String, String> headers,
      Map<String, dynamic> params,
      Function errorCallback}) async {
    String msg;
    int code;
    var data;

    try {
      Map<String, String> headerMap = headers == null ? new Map() : headers;
      Map<String, dynamic> paramMap = params == null ? new Map() : params;

      SharedPreferences sp = await SharedPreferences.getInstance();
      String accessToken = sp.get("accessToken");
      if (accessToken == null || accessToken.length == 0) {
      } else {
        headerMap['accessToken'] = accessToken;
      }

      headerMap['Content-Type'] = 'text/html; charset=utf-8';

      http.Response res;
      if (POST == method) {
        if (!Api.PRODUCT) {
          print("POST:URL=" + url);
          print("POST:HEADER=" + headerMap.toString());
          print("POST:BODY=" + paramMap.toString());
        }
        res = await http.post(url, headers: headerMap, body: json.encode(paramMap), encoding: Encoding.getByName("utf-8"),);
      } else {
        if (!Api.PRODUCT) {
          print("GET:URL=" + url);
          print("GET:HEADER=" + headerMap.toString());
        }
        res = await http.get(url, headers: headerMap,);
      }

      if (res.statusCode != 200) {
        msg = "Network request error: " + res.statusCode.toString();
        handError(errorCallback, msg);
        return;
      }

      String body = utf8.decode(res.bodyBytes);
      if (!Api.PRODUCT) {
        print(body);
      }
      Map<String, dynamic> map = json.decode(body);
      code = map['code'];
      msg = map['message'];
      data = map['data'];

      if (url.contains(Api.LOGIN) && data != null) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString('accessToken', data['token']);
      }

      if (callback != null) {
        if (code == 200) {
          callback(data);
        } else {
          handError(errorCallback, msg);
        }
      }
    } catch (e) {
      handError(errorCallback, e);
    }
  }

  static void handError(Function errorCallback, String errorMsg) {
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
    print("errorMsg :" + errorMsg);
  }
}
