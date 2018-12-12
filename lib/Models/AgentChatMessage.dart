import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';

class AgentChatMessage extends DetailContentChatModel{

  String _message;

  String get message => _message;
  set setMessage(String message) => _message = message;
    AgentChatMessage.fromJson(Map<String,dynamic> data){
      setMapParent(data);
      _message = data['message'];
    }

    AgentChatMessage.fromVisitor({
      String message,
      String id,
      String participantId,
      String type,
      String displayname,
      int timeStamp
    }){
      setMapParentFromvisitor(
        displayName: displayname,
        id: id,
        participantId: participantId,
        timeStamp: timeStamp,
        type: type
      );
      _message = message;
    }
}