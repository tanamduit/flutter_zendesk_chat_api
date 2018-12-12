package com.tanamduit.flutterzendeskchat.listeners;

import com.zopim.android.sdk.api.ChatApi;

public interface ChatListener {

    void onChatLoaded(ChatApi chat);

    void onChatInitialized();

    void onChatEnded();

    void onChatInitializationFailed();

}
