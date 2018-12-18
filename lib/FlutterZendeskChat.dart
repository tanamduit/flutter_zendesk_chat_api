import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_zendesk_chat/Models/DetailContentChatModel.dart';
import 'package:flutter_zendesk_chat/Utils/ConstantCollections.dart';

class FlutterZendeskChat {
  static final MethodChannel _channel =
      const MethodChannel('flutter_zendesk_chat');

  final _agentNotAvailable = new StreamController<Null>.broadcast();
  final _failedVisitorUploadItem = new StreamController<String>.broadcast();
  final _agentIsTyping = new StreamController<Null>.broadcast();
  final _agentIsStopTyping = new StreamController<Null>.broadcast();
  final _accountIsOffline = new StreamController<Null>.broadcast();
  final _accountIsOnline = new StreamController<Null>.broadcast();
  final _chatTimeout = new StreamController<Null>.broadcast();
  final _failedReconnect = new StreamController<Null>.broadcast();
  final _chatConnected = new StreamController<Null>.broadcast();
  final _chatDisConnected = new StreamController<Null>.broadcast();
  final _chatNoConnection = new StreamController<Null>.broadcast();
  final _chatClosed = new StreamController<Null>.broadcast();
  final _chatUnknown = new StreamController<Null>.broadcast();
  final _chatConnecting = new StreamController<Null>.broadcast();
  final _chatObserving = new StreamController<String>.broadcast();


  FlutterZendeskChat(){
    _channel.setMethodCallHandler(handleMethod);
  }

  Future<Null> handleMethod(MethodCall call) async{
    switch(call.method){
      case ConstantCollections.NO_AGENT_ONLINE : 
        _agentNotAvailable.add(null);
        break;

      case ConstantCollections.FAILED_VISITOR_UPLOAD_ITEM : 
        _failedVisitorUploadItem.add(call.arguments['failedUpload']);
        break;

      case ConstantCollections.ACCOUNT_IS_ONLINE :
        _accountIsOnline.add(null);
        break;
      
      case ConstantCollections.ACCOUNT_IS_OFFLINE : 
        _accountIsOffline.add(null);
       break;

      case ConstantCollections.AGENT_IS_TYPING :
        _agentIsTyping.add(null);
        break;

      case ConstantCollections.AGENT_IS_STOP_TYPING :
        _agentIsStopTyping.add(null);
        break;

      case ConstantCollections.FAILED_RECONNECT :
        _failedReconnect.add(Null);
        break;

      case ConstantCollections.CHAT_CONNECTED :
        _chatConnected.add(null);
        break;

      case ConstantCollections.CHAT_DISCONNECTED :
        _chatDisConnected.add(null);
        break;

      case ConstantCollections.CHAT_NO_CONNECTION :
        _chatNoConnection.add(null);
        break;

      case ConstantCollections.CHAT_CLOSE :
        _chatClosed.add(null);
        break;

      case ConstantCollections.CHAT_UNKNOWN :
        _chatUnknown.add(null);
        break;

      case ConstantCollections.CHAT_CONNECTING :
        _chatConnecting.add(null);
        break;

      case ConstantCollections.CHAT_TIMEOUT :
        _chatTimeout.add(null);
        break;

      case ConstantCollections.CHAT_OBSERVING :
        print("masuk sini");
        _chatObserving.add(call.arguments['rowItem']);
        break;
    }
  }


  Future<String> initializeChat({
    String name,
    String email,
    String phone,
    String fcmId,
    String accountKey
  }) async{
    final args = {};
    args['name'] = name;
    args['email'] = email;
    args['phone'] = phone;
    args['fcmId'] = fcmId;
    args['accountKey'] = accountKey;
    return await _channel.invokeMethod("initializationChat", args);
  }

  Future<String> closingChat() async{
    String res = await _channel.invokeMethod("closeChat");
    onDispose();
    return res;
  }

  Future<String> endingChat() async{
    String res = await _channel.invokeMethod("endingChat");
    onDispose();
    return res;
  }

  Future<String> checkConnection() async{
    return await _channel.invokeMethod("checkingConnection");
  }

  Future<bool> sendingTextChat(String text) async{
    Map<String,String> data = new Map<String,String>();
    data['chatType'] = ConstantCollections.CHAT_TYPE_TEXT;
    data['chatText'] = text;
    return await _channel.invokeMethod("sendChat", data);
  }

  Future<String> attachmentFile(String attach, String name) async{
    Map<String,String> data = new Map<String,String>();
    data['chatType'] = ConstantCollections.CHAT_TYPE_FILE;
    data['chatFile'] = attach;
    data['nameFile'] = name;
    return await _channel.invokeMethod("attachmentFile", data);
  }

  Future<bool> transcriptEmail(String email) async{
    Map<String,String> data = new Map<String,String>();
    data['email'] = email;
    return await _channel.invokeMethod("transcriptEmail",data);
  }

  Stream<Null> get onAgentNotAvailable => _agentNotAvailable.stream;
  Stream<String> get onFailedVisitorUploadItem => _failedVisitorUploadItem.stream;
  Stream<Null> get onAgentIsTyping => _agentIsTyping.stream;
  Stream<Null> get onAgentIsStopTyping => _agentIsStopTyping.stream;
  Stream<Null> get onAccountOffline => _accountIsOffline.stream;
  Stream<Null> get onAccountOnline => _accountIsOnline.stream;
  Stream<Null> get onChatTimeout => _chatTimeout.stream;
  Stream<Null> get onFailedReconnect => _failedReconnect.stream;
  Stream<Null> get onChatConnected =>_chatConnected.stream;
  Stream<Null> get onChatDisconnected => _chatDisConnected.stream;
  Stream<Null> get onChatNoConnection => _chatNoConnection.stream;
  Stream<Null> get onChatClosed => _chatClosed.stream;
  Stream<Null> get onChatUnknown => _chatUnknown.stream;
  Stream<Null> get onChatConnecting => _chatConnecting.stream;
  Stream<String> get onObservingChat => _chatObserving.stream;

  onDispose(){
    _agentNotAvailable.close();
    _failedVisitorUploadItem.close();
    _agentIsTyping.close();
    _agentIsStopTyping.close();
    _accountIsOffline.close();
    _accountIsOnline.close();
    _chatTimeout.close();
    _failedReconnect.close();
    _chatConnected.close();
    _chatObserving.close();
    _chatDisConnected.close();
    _chatNoConnection.close();
    _chatClosed.close();
    _chatUnknown.close();
    _chatConnecting.close();
  }

  static Future<bool> playSoundNotification() async{
    return await _channel.invokeMethod("playSoundNotification");
  }

}
