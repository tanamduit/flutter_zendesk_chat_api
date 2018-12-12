package com.tanamduit.flutterzendeskchat.listeners;

public interface ConnectionListener {

    void onConnected();
    void onDisconnected();
    void onConnecting();
    void onUnknown();
    void onClose();
    void onNoConnection();
}
