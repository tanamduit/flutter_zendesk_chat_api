import 'DetailContentChatModel.dart';

class AgentChatOption extends DetailContentChatModel{

  List<String> _options;
  String _message;
  String _selectedOption;

  List<String> get options => _options;
  setOptions(List<String> dt){
    if(_options == null){
      _options = new List<String>();
    }else{
      _options.clear();
    }

    _options.addAll(dt);
  }

  String get message => _message;
  setMessage(String msg){
    _message = msg;
  }

  String get selectedOption => _selectedOption;
  setSelectedOption(String selected){
    _selectedOption = selected;
  }

  AgentChatOption.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    setMessage(data['message']);
    setOptions(data['options'].toString().split("#"));
    if(data['selectedOption'] != null){
      setSelectedOption(data['selectedOption']);
    }
  }

  Map<String,dynamic> getMap(){
    Map<String,dynamic> data = getMapParent();
    data['message'] = message;
    data['options'] = options.join("#");
    if(selectedOption != null){
      data['selectedOption'] = selectedOption;
    }
    return data;
  }
}