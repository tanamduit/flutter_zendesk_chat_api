package com.tanamduit.flutterzendeskchat.observers;

import android.content.Context;
import android.util.Log;

import com.google.gson.JsonObject;
import com.tanamduit.flutterzendeskchat.FlutterZendeskChatPlugin;
import com.zopim.android.sdk.data.observers.ChatItemsObserver;
import com.zopim.android.sdk.model.items.AgentAttachment;
import com.zopim.android.sdk.model.items.AgentMessage;
import com.zopim.android.sdk.model.items.ChatMemberEvent;
import com.zopim.android.sdk.model.items.RowItem;
import com.zopim.android.sdk.model.items.VisitorAttachment;
import com.zopim.android.sdk.model.items.VisitorMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

public class ChatObserver extends ChatItemsObserver {



    public ChatObserver(Context context){
        super(context);
    }
    boolean isFirst = true;
    @Override
    protected void updateChatItems(TreeMap<String, RowItem> treeMap) {
        updateChat(treeMap);
    }

    private void updateChat(TreeMap<String, RowItem> chats){
        Log.e("Chat Observer","observing chat with size :"+ chats.size());
        Iterator i = chats.values().iterator();
        if(isFirst || chats.size() == 0){
            isFirst = false;
            while (i.hasNext()){
                RowItem item = (RowItem)i.next();
                Log.e("Chat Observer", "Chat type : " + item.getType().name());
                Map<String, String> data = new HashMap<>();
                data.put("rowItem", rowItemToString(item));
                FlutterZendeskChatPlugin.channel.invokeMethod("observingChat", data);
            }
        }else {
            RowItem last = chats.lastEntry().getValue();
            if(last != null) {
                Log.e("Chat Observer", "Chat type : " + last.getType().name());
                Map<String, String> data = new HashMap<>();
                data.put("rowItem", rowItemToString(last));
                FlutterZendeskChatPlugin.channel.invokeMethod("observingChat", data);
            }
        }
    }

    private String rowItemToString(RowItem item){
        JSONObject obj = new JSONObject();
        try {
            obj.put("id",item.getId());
            obj.put("participantId",item.getParticipantId());
            obj.put("type",item.getType());
            obj.put("displayName", item.getDisplayName());
            obj.put("timeStamp",item.getTimestamp());
            if(item instanceof AgentMessage){
                obj.put("message", ((AgentMessage) item).getMessage());
            }else if(item instanceof VisitorMessage){
                obj.put("message",((VisitorMessage) item).getMessage());
                obj.put("status",1);
            }else if(item instanceof ChatMemberEvent){
                obj.put("message", ((ChatMemberEvent) item).getMessage());
            }else if(item instanceof AgentAttachment){
                obj.put("path",((AgentAttachment) item).getAttachmentUrl().toExternalForm());
                obj.put("thumbnailPath",((AgentAttachment) item).getAttachmentUrl().toExternalForm());
                obj.put("attachmentName", ((AgentAttachment) item).getAttachmentName());
                obj.put("attachmentSize", ((AgentAttachment) item).getAttachmentSize());
            }else if(item instanceof VisitorAttachment){
                Log.e("visitor-attachment", ((VisitorAttachment)item).toString());
                String pth = "-";
                try{
                    pth = ((VisitorAttachment) item).getFile().getPath();
                    if(pth == null){
                        pth = "-";
                    }
                }catch (Exception e){
                    e.printStackTrace();
                    pth = "-";
                }
                obj.put("message","-");
                obj.put("url", pth);
                obj.put("ekstension",".jpg");
                obj.put("progress", String.valueOf(((VisitorAttachment) item).getUploadProgress()));
            }
            return obj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
    }
}
