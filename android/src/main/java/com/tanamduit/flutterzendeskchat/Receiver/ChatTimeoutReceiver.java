package com.tanamduit.flutterzendeskchat.Receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.tanamduit.flutterzendeskchat.FlutterZendeskChatPlugin;

public class ChatTimeoutReceiver extends BroadcastReceiver {

    public ChatTimeoutReceiver(){

    }

    @Override
    public void onReceive(Context context, Intent intent) {
        FlutterZendeskChatPlugin.channel.invokeMethod("chatTimeout",null);
    }
}
