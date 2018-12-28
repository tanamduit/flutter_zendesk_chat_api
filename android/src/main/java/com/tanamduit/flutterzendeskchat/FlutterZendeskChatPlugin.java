package com.tanamduit.flutterzendeskchat;

import android.app.Application;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry;

import com.tanamduit.flutterzendeskchat.listeners.ChatListener;
import com.zendesk.belvedere.BelvedereCallback;
import com.zendesk.belvedere.BelvedereResult;
import com.zendesk.logger.Logger;
import com.zopim.android.sdk.api.ChatService;
import com.zopim.android.sdk.api.ChatServiceBinder;
import com.zopim.android.sdk.api.ZopimChatApi;
import com.zopim.android.sdk.data.observers.ConnectionObserver;
import com.zopim.android.sdk.model.Account;
import com.zopim.android.sdk.model.ChatLog;
import com.zopim.android.sdk.model.Connection;
import com.zopim.android.sdk.api.ChatApi;
import com.zopim.android.sdk.model.Department;
import com.zopim.android.sdk.model.VisitorInfo;
import com.zopim.android.sdk.util.BelvedereProvider;

import java.io.File;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;


/** FlutterZendeskChatPlugin */
public class FlutterZendeskChatPlugin implements MethodCallHandler,ChatListener,PluginRegistry.ActivityResultListener{
  private Registrar vRegistrar;
  private ChatApi chat;
  private Handler handler = new Handler(Looper.getMainLooper());
  private ChatDelegate chatDelegate;
  public static MethodChannel channel;
  public Result vResult;

  private BroadcastReceiver chatInitializationTimeOut = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      onChatInitializationFailed();
      //should trigger broadcast error timeout
    }
  };

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "flutter_zendesk_chat");
    channel.setMethodCallHandler(new FlutterZendeskChatPlugin(registrar));
  }


  public FlutterZendeskChatPlugin(Registrar registrar){
    vRegistrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    vResult = result;
    if (call.method.equals("initializationChat")) {
      String accKey = call.argument("accountKey");
      String email = call.argument("email");
      String phone = call.argument("phone");
      String name = call.argument("name");
      String fcm = call.argument("fcmId");
      ZopimChatApi.init(accKey);
      ZopimChatApi.setVisitorInfo(new VisitorInfo.Builder()
      .email(email)
      .name(name)
      .phoneNumber(phone)
      .build());
      //ZopimChatApi.setPushToken(fcm);
      ChatApi tmpChat = ZopimChatApi.start((FragmentActivity) vRegistrar.activity());
      onChatLoaded(tmpChat);
      IntentFilter initializationTimeoutFilter = new IntentFilter("chat.action.INITIALIZATION_TIMEOUT");
      LocalBroadcastManager.getInstance(vRegistrar.activeContext()).registerReceiver(chatInitializationTimeOut, initializationTimeoutFilter);
      vResult.success("initialized");
    }else if(call.method.equals("closeChat")) {
      onChatClosed();
      vResult.success("closed");
    }else if(call.method.equals("endingChat")) {
      onChatEnded();
      vResult.success("end");
    }else if(call.method.equals("transcriptEmail")){
      if(chat != null){
        String email = call.argument("email");
        chat.emailTranscript(email);
      }
      vResult.success(true);
    }else if(call.method.equals("sendChat")) {
      String chatType = call.argument("chatType");
      if (chatType.equalsIgnoreCase("text")) {
        String contennt = call.argument("chatText");
        chat.send(contennt);
        Log.e("zendeskChat", "message sent to agent : " + contennt);
        vResult.success(true);
      } else if (chatType.equalsIgnoreCase("file")) {

      }
    }else if(call.method.equals("checkingConnection")){

        if(chat == null){
          vResult.success("uninitialized");
        }else{
          Connection connection = ZopimChatApi.getDataSource().getConnection();
          vResult.success(connection.getStatus().toString());
        }

    }else if(call.method.equals("playSoundNotification")) {
      try {
        Uri notif = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        Ringtone r = RingtoneManager.getRingtone(vRegistrar.activeContext(), notif);
        r.play();
        Log.e("zendeskChat", "ringtone played");
        vResult.success(true);
      } catch (Exception e) {
        e.printStackTrace();
        vResult.success(false);
      }
    }else if(call.method.equals("attachmentFile")) {
      String pth = call.argument("chatFile");
      String name = call.argument("nameFile");
      File file = new File(pth);
      chat.send(file);
    }else if(call.method.equals("sendRating")) {
      String rating = call.argument("rating");
      if (chat != null) {
        chat.sendChatRating(getRating(rating));
      }
      vResult.success("rated");
    }else if(call.method.equals("sendComment")){
      String comment = call.argument("comment");
      if(chat != null){
        chat.sendChatComment(comment);
      }
      vResult.success("commented");
    } else {
      vResult.notImplemented();
    }
  }

  ChatLog.Rating getRating(String rt){
    if(rt.equals("good")){
      return ChatLog.Rating.GOOD;
    }else if(rt.equals("bad")){
      return  ChatLog.Rating.BAD;
    }else if(rt.equals("unknown")){
      return  ChatLog.Rating.UNKNOWN;
    }else{
      return  ChatLog.Rating.UNRATED;
    }
  }

  @Override
  public void onChatInitializationFailed(){
    handler.post(new Runnable() {
      @Override
      public void run() {
        chat.endChat();
      }
    });
  }


  @Override
  public void onChatLoaded(ChatApi chat) {
    this.chat = chat;
    chatDelegate = new ChatDelegate(vRegistrar,this.chat,this);
  }

  @Override
  public void onChatInitialized(){
    chatInitialized();
  }

  public void chatInitialized(){

    Account acc = ZopimChatApi.getDataSource().getAccount();
    if(acc != null &&  acc.getStatus() == Account.Status.OFFLINE){
       // no agent layout
       channel.invokeMethod("noAgentOnline", null);
    }else{
      // start chat;
    }
  }

  @Override
  public void onChatEnded() {
    onChatClosed();
    ZopimChatApi.getDataSource().deleteObservers();
    ZopimChatApi.getDataSource().clear();
  }

  @Override
  public void onChatClosed() {
    vRegistrar.activeContext().stopService(new Intent(vRegistrar.activeContext(), ChatService.class));
    Log.e("flutter_zendesk_chat","Closing chat");
    handler.removeCallbacksAndMessages((Object)null);
    chatDelegate.stoppingChat();
    if(chat != null) {
      if(!chat.hasEnded()){
        chat.endChat();
      }
      chat = null;
    }
    LocalBroadcastManager.getInstance(vRegistrar.activeContext()).unregisterReceiver(chatInitializationTimeOut);
    FragmentActivity  act = (FragmentActivity)vRegistrar.activity();
    FragmentManager manager = act.getSupportFragmentManager();
    ChatServiceBinder binder = (ChatServiceBinder)manager.findFragmentByTag(ChatServiceBinder.class.getName());
    if(binder != null){
      Log.e("flutter_zendesk_chat", "chat service binder is found");
      manager.beginTransaction().remove(binder).commit();
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    BelvedereProvider.INSTANCE.getInstance(vRegistrar.activeContext()).getFilesFromActivityOnResult(requestCode, resultCode, data, new BelvedereCallback<List<BelvedereResult>>() {
      public void success(List<BelvedereResult> results) {
        if (results == null) {
          Logger.i("ZopimChatLogFragment", "No files selected for upload.", new Object[0]);
          vResult.success(null);
        } else {
          Logger.i("ZopimChatLogFragment", "Sending " + results.size(), new Object[0]);
          Iterator var2 = results.iterator();

          while(var2.hasNext()) {
            BelvedereResult result = (BelvedereResult)var2.next();
            File file = result.getFile();
            if (file != null) {
              chat.send(file);
              vResult.success(file.getPath());
            } else {
              Logger.w("ZopimChatLogFragment", "Failed to send a file. File was null.", new Object[0]);
              vResult.success("notFound");
            }
          }

        }
      }
    });
    return true;
  }

}
