import 'dart:convert';

import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';

class VisitorChatMessage extends DetailContentChatModel{

  String _message;

  //0 delivering
  //1 delvered
  int _status;

  VisitorChatMessage.fromJson(Map<String,dynamic> data){
      print(json.encode(data));
      setMapParent(data);
        _message = data['message'];
        _status =  data["status"] == null ? 0 : int.parse(data['status'].toString());
  }

  int get status => _status;
  String get message => _message;

  void setStatus(int status){
     _status = status;
  }
  void setMessage(String message){
    _message = message;
  }

  Map<String,dynamic> getMap(){
    Map<String, dynamic> data = new Map<String,dynamic>();
    data = getMapParent();
    data['message'] = _message;
    data['status'] = _status;
    return data;
  }
}