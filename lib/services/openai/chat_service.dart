import 'package:http/http.dart' as http;
import 'openai_api_key.dart';
import '../../models/openai/chat_request.dart';
import '../../models/openai/chat_response.dart';
import '../../models/openai/message.dart';

class ChatService {
  static final Uri chatUri = Uri.parse(
      'https://api.openai.com/v1/chat/completions');

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${OpenaiApiKey.openAIApiKey}',
  };

  Future<String?> request(String prompt) async {
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo",
          maxTokens: 150,
          messages: [Message(role: "system", content: prompt)]);
      if (prompt.isEmpty) {
        return null;
      }
      http.Response response = await http.post(
        chatUri,
        headers: headers,
        body: request.toJson(),
      );
      ChatResponse chatResponse = ChatResponse.fromResponse(response);
      return chatResponse.choices?[0].message?.content;
    } catch (e) {
      print("error $e");
    }
    return null;
  }
}