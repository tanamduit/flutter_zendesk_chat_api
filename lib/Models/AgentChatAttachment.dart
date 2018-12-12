import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';

class AgentChatAttachment extends DetailContentChatModel{

  String _path;
  String _thumbnailPath;
  String _attachmentName;
  double _attachmentSize;

  String get path => _path;
  String get attachmentName => _attachmentName;
  String get thumbnailPath => _thumbnailPath;
  double get attachmentSize => _attachmentSize;

  AgentChatAttachment.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    _path = data['path'];
    _thumbnailPath = data['thumbnailPath'];
    _attachmentName = data['attachmentName'];
    _attachmentSize = double.parse(data['attachmentSize'].toString());
  }
}