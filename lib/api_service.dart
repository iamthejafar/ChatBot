import 'dart:convert';

import 'package:http/http.dart' as http;
String apikey = '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';
class ApiService{

  static String baseurl = 'https://api.openapi.com/v1/completions';


  static Map<String,String> header = {
    'Content-Type':'application/json',
    'Authorization':'Bearer $apikey'};
  static sendMessage(String? message) async{
    var url = Uri.https("api.openai.com", "/v1/completions");

    var res = await http.post(
      url,
      headers: header,
      body: jsonEncode({
        "model":"text-davinci-003",
          "prompt":'$message',
          "temperature":0,
          "max_tokens":100,
          "top_p":1,
          "frequency_penalty":0.0,
          "presence_penalty":0.0,
          "stop":[" Human:"," AI"]
        }
      )
    );

    print(res.statusCode);
    // print(res.body);
    if(res.statusCode == 200){
      var data = jsonDecode(res.body.toString());
      var msg = data['choices'][0]['text'].toString();
      // print(msg);
      return msg;
    }
    else{
      print('Failed to load');
    }

  }



}