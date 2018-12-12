class DetailContentChatModel{
  String _id;
  String _participantId;
  String _type;
  String _displayName;
  int _timeStamp;

  DetailContentChatModel();

  DetailContentChatModel.fromJson(Map<String,dynamic> data){
    setMapParent(data);
  }

  setMapParent(Map<String,dynamic> data){
    _id = data['id'];
    _participantId = data['participantId'];
    _type = data['type'];
    _displayName = data['displayName'];
    _timeStamp = int.parse(data['timeStamp'].toString()); 
  }

  setMapParentFromvisitor({
    String id,
    String participantId,
    String type,
    String displayName,
    int timeStamp
  }){
    _id = id;
    _participantId = participantId;
    _type = type;
    _displayName = displayName;
    _timeStamp = timeStamp;
  }

  String get id => _id;
  String get participantId => _participantId;
  String get type => _type;
  String get displayName => _displayName;
  int get timeStamp => _timeStamp;

  void setId(String id) => _id = id;
  void setParticipantId(String participantId) => _participantId = participantId;
  void setDisplayName(String name) => _displayName = displayName;

  Map<String,dynamic> getMapParent(){
    Map<String,dynamic> data= new Map<String,dynamic>();
    data['id'] = _id;
    data['participantId'] = _participantId;
    data['type'] = _type;
    data['displayName'] = _displayName;
    data['timeStamp'] = _timeStamp;
    return data;
  }
}