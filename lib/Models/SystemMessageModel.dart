import 'DetailContentChatModel.dart';

class SystemMessageModel extends DetailContentChatModel{

  String _message;
  String get message => _message;
  setMessage(String message){
    _message = message;
  }
  int _queue;
  int get queue => _queue;
  setQueue(int q){
    _queue = q;
  }

  SystemMessageModel.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    setMessage(data['message']);
    if(data['queue'] != null){
      setQueue(int.parse(data['queue'].toString()));
    }else{
      setQueue(-1);
    }
  }
}