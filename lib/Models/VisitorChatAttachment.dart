import 'dart:convert';
import 'dart:io';

import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';

class VisitorChatAttachment extends DetailContentChatModel{

  String _path;
  String _message;
  String _ekstension;
  double _progress;

  
  VisitorChatAttachment.fromJson(Map<String,dynamic> data){
    print("model visitor chat attachment : "+json.encode(data));
    setMapParent(data); 
    _message = data['message'];
    _path = data['url'];
    _ekstension = data['ekstension'];
    _progress = double.parse(data['progress'].toString());
    if(Platform.isAndroid){
      if(_progress > 0 && _progress < 100){
        _progress = 100.0;
      }
    }
  }

  VisitorChatAttachment.setFromSending({
    String id,
    String displayName,
    String participantId,
    String type,
    int timeStamp 
  }){
    setMapParentFromvisitor(
      id: id,
      displayName: displayName,
      participantId: participantId,
      type: type,
      timeStamp: timeStamp 
    );
  }

  Map<String,dynamic> getMap(){
    Map<String,dynamic> data = new Map<String,dynamic>();
    data = getMapParent();
    data['url'] = _path;
    data['message'] = _message;
    data['ekstension'] = _ekstension;
    data['progress'] = _progress;
    return data;
  }

  String get path => _path;
  String get message => _message;
  String get ekstension => _ekstension;
  double get progress => _progress;

  setMessage(String message) => _message = message;
  setPath(String path) => _path = path;
  setEkstension(String eks) => _ekstension = eks;
  setProgress(dynamic progress){
    _progress = double.parse(progress.toString());
  }
}