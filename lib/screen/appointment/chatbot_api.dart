import 'dart:convert';

import 'package:http/http.dart' as http;
class ChatBot_Api {
  static Future<Map<String, String>> getHeader() async {
    return {
      'Content-Type': 'application/json',
    };
  }

  static Future<String> getChatData(message) async {
    try {
      final header = await getHeader();

      final Map<String, dynamic> requestBody = {
        'content': [
          {
            'parts': [
              {'text': 'user message request here $message'}
            ]
          }
        ],
        'generationConfig':{
          'temperature' : 0.8,
          'maxOutputTokens': 1000
        }
      };
      String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAlEfRlE4ls1oLmD4PQEybAMmWlD71-XQw';

      var response  = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(requestBody),
      );
      print(response.body);
      if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          return jsonResponse['candidate'][0]['content']['parts'][0]['text'];
      }else{
        return '';
      }

    } catch (e) {
      print("Error: $e");
      return " ";
    }
  }
}
