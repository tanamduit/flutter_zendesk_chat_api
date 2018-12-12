package com.tanamduit.flutterzendeskchat.observers;

import android.content.Context;
import android.os.Handler;

import com.tanamduit.flutterzendeskchat.FlutterZendeskChatPlugin;
import com.zopim.android.sdk.data.observers.AgentsTypingObserver;
import com.zopim.android.sdk.model.items.AgentTyping;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class AgentTypingObserver extends AgentsTypingObserver {

    Handler handler;

    public AgentTypingObserver(Context context){
        super(context);
        handler = new Handler();
    }

    @Override
    protected void updateTyping(final Map<String, AgentTyping> map) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Iterator i =  map.values().iterator();
                while (i.hasNext()){
                    AgentTyping agentTyping = (AgentTyping)i.next();
                    updateAgentTyping(agentTyping);
                }
            }
        });

    }

    private void updateAgentTyping(AgentTyping agentTyping){
        if(agentTyping != null){
            //must be channel
            FlutterZendeskChatPlugin.channel.invokeMethod("agentIsTyping",null);
        }
    }
}
