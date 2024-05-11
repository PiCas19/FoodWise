import 'message.dart';

class Choice {
  final int? index;
  final Message? message;
  final String? finishReason;

  Choice(this.index, this.message, this.finishReason);

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      json['index'],
      Message.fromJson(json['message']),
      json['finish_reason'],
    );
  }
}