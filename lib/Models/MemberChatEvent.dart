import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';

class MemberChatEvent extends DetailContentChatModel{
  
  String _message;

  String get message => _message;

  MemberChatEvent.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    _message = data['message'];
  }
}