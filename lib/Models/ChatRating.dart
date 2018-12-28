import 'DetailContentChatModel.dart';

class ChatRating extends DetailContentChatModel{

  String _comment;
  String _rating;

  String get comment => _comment;
  String get rating => _rating;

  setComment(String comment)=> _comment = comment;
  setRating(String rating) => _rating = rating;

  ChatRating.fromJson(Map<String,dynamic> data){
    setMapParent(data);
    if(data['comment'] != null){
      setComment(data['comment']);
    }

    if(data['rating'] != null){
      setRating(data['rating']);
    }
  }

  Map<String,dynamic> getMap(){
    Map<String,dynamic> data = new Map<String,dynamic>();
    data = getMapParent();
    data['rating'] = rating;
    data['comment'] = comment;
    return data;
  }
}