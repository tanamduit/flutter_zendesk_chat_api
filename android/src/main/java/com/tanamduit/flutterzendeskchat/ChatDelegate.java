package com.tanamduit.flutterzendeskchat;

import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.util.Log;

import com.tanamduit.flutterzendeskchat.Receiver.ChatTimeoutReceiver;
import com.tanamduit.flutterzendeskchat.listeners.ChatListener;
import com.tanamduit.flutterzendeskchat.listeners.ConnectionListener;
import com.tanamduit.flutterzendeskchat.listeners.NotificationListener;
import com.tanamduit.flutterzendeskchat.observers.AgentTypingObserver;
import com.tanamduit.flutterzendeskchat.observers.ChatObserver;
import com.zopim.android.sdk.api.ChatApi;
import com.zopim.android.sdk.api.ChatSession;
import com.zopim.android.sdk.api.ZopimChatApi;
import com.zopim.android.sdk.data.observers.AccountObserver;
import com.zopim.android.sdk.data.observers.ConnectionObserver;
import com.zopim.android.sdk.model.Account;
import com.zopim.android.sdk.model.Connection;


import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
public class ChatDelegate implements ConnectionListener,NotificationListener {

    private long reconnectTimeout = ChatSession.DEFAULT_RECONNECT_TIMEOUT;
    private ChatTimeoutReceiver vChatTimeoutReceiver;
    public ArrayList<String> failedVisitorUploadItems;
    public ChatListener vChatListener;
    private ChatApi vChatApi;
    private AgentTypingObserver agentTypingObserver;
    private ChatObserver chatObserver;
    private AccountObserver accountObserver;
    private ConnectionObserver vConnectionObserver;
    private Registrar vRegistrar;
    private Handler handler = new Handler(Looper.getMainLooper());
    Runnable reconnectFailed;

    public ChatDelegate(Registrar registrar,ChatApi chatApi,ChatListener chatListener){
        vRegistrar = registrar;
        vChatTimeoutReceiver = new ChatTimeoutReceiver();
        failedVisitorUploadItems = new ArrayList<>();
        vChatListener = chatListener;
        vChatApi = chatApi;
        agentTypingObserver = new AgentTypingObserver(vRegistrar.activeContext());
        chatObserver = new ChatObserver(vRegistrar.activeContext());
        reconnectFailed = new Runnable() {
            @Override
            public void run() {
                Log.e("zendeskChat","Failed reconnect");
                FlutterZendeskChatPlugin.channel.invokeMethod("failedReconnect",null);
            }
        };
        accountObserver = new AccountObserver() {
            @Override
            public void update(Account acc) {
                //something triggering with chat
                statusAccount(acc);
            }
        };

        vConnectionObserver = new ConnectionObserver(){
            @Override
            protected void update(Connection connection) {
                statusConnection(connection);
            }
        };

        Account account = ZopimChatApi.getDataSource().getAccount();
        if(account != null){
            if(account.getStatus() == Account.Status.OFFLINE){
                handler.postDelayed(new Runnable(){
                    @Override
                    public void run() {
                        Log.e("ZendeskChat","Online Account");
                        FlutterZendeskChatPlugin.channel.invokeMethod("accountIsOnline",null);
                    }
                },TimeUnit.SECONDS.toMillis(10L));
            }
        }

        Connection connection = ZopimChatApi.getDataSource().getConnection();
        if(connection != null){
            statusConnection(connection);
        }
        ZopimChatApi.getDataSource().addAccountObserver(accountObserver).trigger();
        //ZopimChatApi.getDataSource().addAgentsObserver(agentTypingObserver).trigger();
        //ZopimChatApi.getDataSource().addChatLogObserver(chatObserver).trigger();
        ZopimChatApi.getDataSource().addConnectionObserver(vConnectionObserver);
        LocalBroadcastManager.getInstance(vRegistrar.activeContext()).registerReceiver(vChatTimeoutReceiver,new IntentFilter("chat.action.TIMEOUT"));
        chatListener.onChatInitialized();
    }

    Runnable offlineRunnable = new Runnable() {
        @Override
        public void run() {
            Log.e("ZendeskChat","Offline Account");
            FlutterZendeskChatPlugin.channel.invokeMethod("accountIsOffline",null);
        }
    };

    Runnable onlineRunnable = new Runnable() {
        @Override
        public void run() {
            Log.e("ZendeskChat","Online Account");
            FlutterZendeskChatPlugin.channel.invokeMethod("accountIsOnline",null);
        }
    };


    public void statusAccount(Account acc){
        if(acc != null){
            Account.Status stat = acc.getStatus();
            if(stat != null){
                switch (stat){
                    case OFFLINE:
                        handler.removeCallbacks(onlineRunnable);
                        handler.removeCallbacks(offlineRunnable);
                        handler.post(offlineRunnable);
                        break;

                    case UNKNOWN:
                        handler.removeCallbacks(onlineRunnable);
                        handler.removeCallbacks(offlineRunnable);
                        handler.post(offlineRunnable);
                        break;

                    case ONLINE:
                        handler.removeCallbacks(offlineRunnable);
                        handler.removeCallbacks(onlineRunnable);
                        handler.post(onlineRunnable);
                        break;
                }
            }
        }
    }

    public void statusConnection(Connection connection){

        if(!vChatApi.hasEnded()){
            switch (connection.getStatus()){
                case NO_CONNECTION:
                    if(!vChatApi.hasEnded()) {
                        vChatListener.onChatInitializationFailed();
                    }
                    onShowNotification();
                    onNoConnection();
                    break;

                case DISCONNECTED:
                    if(!vChatApi.hasEnded()) {
                        vChatListener.onChatInitializationFailed();
                    }
                    onDisconnected();
                    break;

                case CLOSED:
                    if(!vChatApi.hasEnded()){
                        vChatListener.onChatInitializationFailed();
                    }
                    onClose();
                    break;

                case UNKNOWN:
                    onUnknown();
                    break;

                case CONNECTING:
                    onConnecting();
                    break;

                case CONNECTED:
                    onHideNOtification();
                    onConnected();
                    break;
            }
        }else{
            Log.e("flutter_zendesk_chat","Chat has ended detected by connection observer");
            onDisconnected();

        }

    }

    public void stoppingChat(){
        ZopimChatApi.getDataSource().deleteAccountObserver(accountObserver);
        ZopimChatApi.getDataSource().deleteAgentsObserver(agentTypingObserver);
        ZopimChatApi.getDataSource().deleteChatLogObserver(chatObserver);
        ZopimChatApi.getDataSource().deleteConnectionObserver(vConnectionObserver);
        LocalBroadcastManager.getInstance(vRegistrar.activeContext()).unregisterReceiver(vChatTimeoutReceiver);
    }

    @Override
    public void onConnected() {
        Log.e("zendeskChat","Chatting connected");
        handler.removeCallbacks(reconnectFailed);
        FlutterZendeskChatPlugin.channel.invokeMethod("chatConnected",null);
    }

    @Override
    public void onDisconnected() {
        Log.e("zendeskChat","Chatting disconnected");
        FlutterZendeskChatPlugin.channel.invokeMethod("chatDisconnected",null);
    }

    @Override
    public void onConnecting() {
        Log.e("zendeskChat","Connecting chat");
        FlutterZendeskChatPlugin.channel.invokeMethod("chatConnecting",null);
    }

    @Override
    public void onUnknown() {
        Log.e("zendeskChat","Unknown Chat");
        FlutterZendeskChatPlugin.channel.invokeMethod("chatUnknown",null);
    }

    @Override
    public void onClose() {
        Log.e("zendeskChat","Close Chat");
        FlutterZendeskChatPlugin.channel.invokeMethod("chatClose",null);
    }

    @Override
    public void onNoConnection() {
        Log.e("zendeskChat","No Connection");
        FlutterZendeskChatPlugin.channel.invokeMethod("chatNoConnection",null);
    }


    @Override
    public void onShowNotification() {
        handler.removeCallbacks(reconnectFailed);
        handler.postDelayed(reconnectFailed, reconnectTimeout);
    }

    @Override
    public void onHideNOtification() {
        handler.removeCallbacks(reconnectFailed);
    }
}
