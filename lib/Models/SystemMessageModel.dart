import 'DetailContentChatModel.dart';

class SystemMessageModel extends DetailContentChatModel{

  String _message;
  String get message => _message;
  setMessage(String message){
    _message = message;
  }
  SystemMessageModel.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    setMessage(data['message']);
  }
}