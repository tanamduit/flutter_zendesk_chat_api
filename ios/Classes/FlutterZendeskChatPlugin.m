#import "FlutterZendeskChatPlugin.h"
#import <ZDCChatAPI/ZDCLog.h>
#import <ZDCChatAPI/ZDCChatAPI.h>

@implementation FlutterZendeskChatPlugin

ZDCChatAPI *chat;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zendesk_chat"
            binaryMessenger:[registrar messenger]];
  FlutterZendeskChatPlugin* instance = [[FlutterZendeskChatPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initializationChat" isEqualToString:call.method]) {
      [self initiateChat:call withResult:result];
  } else if([@"sendChat" isEqualToString:call.method]){
      [self sendingMessage:call result:result];
  }else if([@"attachmentFile" isEqualToString: call.method]){
      [self sendingMessage:call result:result];
  }else if([@"closeChat" isEqualToString:call.method]){
      [self closingChat:result];
  }else if([@"endingChat" isEqualToString:call.method]){
      [self endingChat:result];
  }else if([@"transcriptEmail" isEqualToString:call.method]){
      [self transcriptChat:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)transcriptChat:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *email = call.arguments[@"email"];
    [chat emailTranscript:email];
    result(@YES);
}

- (void)closingChat:(FlutterResult)result{
    [self removingObserver];
    //[chat endChat];
    chat = nil;
    result(@"END");
}

- (void)endingChat:(FlutterResult)result{
    [self removingObserver];
    [chat endChat];
    chat = nil;
    result(@"END");
}
       
- (void)removingObserver{
    [chat removeObserverForConnectionEvents:self];
    [chat removeObserverForTimeoutEvents:self];
    [chat removeObserverForChatLogEvents:self];
    [chat removeObserverForAgentEvents:self];
    [chat removeObserverForUploadEvents:self];
    [chat removeObserverForAccountEvents:self];
}
       
       
- (void)sendingMessage:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *type = call.arguments[@"chatType"];
    if([@"text" isEqualToString:type]){
        NSString *msg = call.arguments[@"chatText"];
        [chat sendChatMessage:msg];
        result(@YES);
    }else if([@"file" isEqualToString:type]){
        NSString *pth = call.arguments[@"chatFile"];
        NSString *name = call.arguments[@"nameFile"];
        UIImage *image = [UIImage imageWithContentsOfFile:pth];
        NSLog(@"path file : %@",pth);
        NSLog(@"name : %@",name);
        [chat uploadImage:image name:name];
        result(@"uploading");
    }
}

- (void) sendingFile:(FlutterMethodCall*)call result:(FlutterResult)result{
    
}

- (void)initiateChat:(FlutterMethodCall*)call withResult:(FlutterResult)result{
    NSString *accKey = call.arguments[@"accountKey"];
    NSString *phone = call.arguments[@"phone"];
    NSString *email = call.arguments[@"email"];
    NSString *name = call.arguments[@"name"];
    NSString *fcmId = call.arguments[@"fcmId"];
    [ZDCLog enable:@YES];
    [ZDCLog setLogLevel:ZDCLogLevelVerbose];
    NSLog(@"account key :  %@",accKey);
    NSLog(@"Name :  %@",name);
    NSLog(@"Phone:  %@",phone);
    NSLog(@"Email :  %@",email);
    _isFirstTime = YES;
    chat =  [ZDCChatAPI instance];
    chat.visitorInfo.name = name;
    chat.visitorInfo.email = email;
    chat.visitorInfo.phone = phone;
    [chat startChatWithAccountKey:accKey];
    [self accountState];
    [self connectionState];
    [self chatLogObserving];
    [chat addObserver:self forConnectionEvents:@selector(connectionState)];
    [chat addObserver:self forTimeoutEvents:@selector(chatIsTimeout)];
    [chat addObserver:self forChatLogEvents:@selector(chatLogObserving)];
    [chat addObserver:self forAgentEvents:@selector(agentState)];
    [chat addObserver:self forUploadEvents:@selector(uploadingFile)];
    [chat addObserver:self forAccountEvents:@selector(accountState)];
    result(@"initialized");
}


- (void) agentState{
    NSDictionary *agents = [chat agents];
    
    NSLog(@"agents : %@",agents);
    ZDCChatAgent *agent;
    for(NSString *key in agents){
        agent = [agents objectForKey:key];
    }
    if(agent != nil){
        NSLog(@"id : %@",agent.agentId);
        NSLog(@"display name : %@",agent.displayName);
        NSLog(@"title : %@",agent.title);
        NSLog(@"typing : %@",agent.typing ? @"YES" : @"NO");
        if(agent.typing){
            [channel invokeMethod:@"agentIsTyping" arguments:nil];
        }else{
            [channel invokeMethod:@"agentIsStopTyping" arguments:nil];
        }
    }
}

- (void) connectionState{
    ZDCConnectionStatus stat = [chat connectionStatus];
    switch (stat) {
        case ZDCConnectionStatusUninitialized:
            NSLog(@"status koneksi uninitialized");
            [channel invokeMethod:@"chatUnknown" arguments:nil];
            break;
            
        case ZDCConnectionStatusConnecting:
            NSLog(@"status koneksi menghubungkan");
            [channel invokeMethod:@"chatConnecting" arguments:nil];
            break;
            
        case ZDCConnectionStatusConnected:
            NSLog(@"status koneksi terhubung");
            [channel invokeMethod:@"chatConnected" arguments:nil];
            break;
            
        case ZDCConnectionStatusClosed:
            NSLog(@"status koneksi ditutup");
            [channel invokeMethod:@"chatClose" arguments:nil];
            break;
            
        case ZDCConnectionStatusDisconnected:
            NSLog(@"status koneksi terputus");
            [channel invokeMethod:@"chatDisconnected" arguments:nil];
            break;
            
        case ZDCConnectionStatusNoConnection:
            NSLog(@"status koneksi tidak ada");
            [channel invokeMethod:@"chatNoConnection" arguments:nil];
            break;
            
        default:
            NSLog(@"status koneksi uninitialized(default case)");
            [channel invokeMethod:@"chatUnknown" arguments:nil];
            break;
    }
}


- (void) uploadingFile{
    //uploading file
    NSLog(@"file uploaded");
    [self chatLogObserving];
}

- (void) accountState{
    if(chat.isAccountOnline){
        [channel invokeMethod:@"accountIsOnline" arguments:nil];
    }else{
        [channel invokeMethod:@"accountIsOffline" arguments:nil];
    }
}

- (void) chatIsTimeout{
    [channel invokeMethod:@"chatTimeout" arguments:nil];
}

- (void) chatLogObserving{
    NSArray* events = [chat livechatLog];
    NSLog(@"events count : %d",[events count]);
    if(_isFirstTime){
        _isFirstTime = NO;
        for (ZDCChatEvent *event in events) {
            NSLog(@"check loop event chat");
            [self handleChatLog:event];
        }
    }else{
        ZDCChatEvent *event = [events lastObject];
        [self handleChatLog:event];
    }
}

- (void) handleChatLog:(ZDCChatEvent*)event{
    switch (event.type) {
        case ZDCChatEventTypeMemberJoin:
            [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getTextMemberEvent:event]}];
            break;
            
        case ZDCChatEventTypeMemberLeave:
            [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getTextMemberEvent:event]}];
            break;
            
        case ZDCChatEventTypeAgentMessage:
            [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getTextChatObserving:event]}];
            break;
            
        case ZDCChatEventTypeVisitorMessage:
            [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getTextChatObserving:event]}];
            //[self getTextChatObserving:event];
            break;
            
        case ZDCChatEventTypeVisitorUpload:
           
            if([self getUploadVisitor:event] != nil){
                [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getUploadVisitor:event]}];
            }
            break;
            
        case ZDCChatEventTypeAgentUpload:
            [channel invokeMethod:@"observingChat" arguments:@{@"rowItem":[self getTextAgentAttachment:event]}];
            break;
            
        default:
            break;
    }
}

-(NSString *)getUploadVisitor:(ZDCChatEvent*)data{
    @try{
        NSString *msg = @"-";
        if(data.message != nil){
            msg = data.message;
        }
        
        NSString *ekstension = data.fileUpload.fileExtension;
        if(ekstension == nil){
            ekstension = @".jpg";
        }
        
        NSString *attachmentUrl=@"-";
        if(data.attachment.url != nil){
            attachmentUrl = data.attachment.url;
        }
        
        NSString *displayName =@"";
        if(data.displayName != nil){
            displayName = data.displayName;
        }
        
        NSDictionary *dict = @{
           @"id":data.eventId,
           @"participantId":@"0",
           @"type":@"VISITOR_ATTACHMENT",
           @"displayName":displayName,
           @"timeStamp":data.timestamp,
           @"url":attachmentUrl,
           @"message":msg,
           @"ekstension":ekstension,
           @"progress": [NSNumber numberWithFloat:data.fileUpload.progress]
        };
        
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if(error){
            NSLog(@"gagal serialize");
            return nil;
        }
        NSString *newStr = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"upload visitor : %@",newStr);
        return newStr;
    }
    @catch(NSException *exception){
        NSLog(@"crash : %@",exception);
        return nil;
    }
}


-(NSString *)getTextAgentAttachment:(ZDCChatEvent*)data{
    NSLog(@"path: %@",data.attachment.url);
    NSLog(@"thumbnail: %@",data.attachment.thumbnailURL);
    NSLog(@"size: %d", data.attachment.fileSize);
    
    
    NSDictionary *dict = @{
           @"id":data.eventId,
           @"participantId":@"0",
           @"type":@"AGENT_ATTACHMENT",
           @"displayName":data.displayName,
           @"timeStamp":data.timestamp,
           @"path":data.attachment.url,
           @"thumbnailPath":data.attachment.url,
           @"attachmentName":@"agent-attachment",
           @"attachmentSize":data.attachment.fileSize
           };
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if(error){
        NSLog(@"gagal serialize : %@",error);
    }
    NSString *newStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return newStr;
}

-(NSString *)getTextMemberEvent:(ZDCChatEvent*)data{
    if(data.type == ZDCChatEventTypeMemberJoin){
        data.message = @"Agent has joined";
    }else if(data.type == ZDCChatEventTypeMemberLeave){
        data.message = @"Agent has left";
    }
    
    NSDictionary *dict = @{@"id":data.eventId,
                           @"participantId":@"0",
                           @"type":@"MEMBER_EVENT",
                           @"displayName":data.displayName,
                           @"timeStamp":data.timestamp,
                           @"message":data.message,
                           };
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if(error){
        NSLog(@"gagal serialize : %@",error);
    }
    NSString *newStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return newStr;
}

-(NSString *)getTextChatObserving:(ZDCChatEvent*)data{
    NSString *type;
    if(data.type == ZDCChatEventTypeVisitorMessage){
        type = @"VISITOR_MESSAGE";
    }else if(data.type == ZDCChatEventTypeAgentMessage){
        type = @"AGENT_MESSAGE";
    }
    NSDictionary *dict = @{@"id":data.eventId,
                           @"participantId":@"0",
                           @"type":type,
                           @"displayName":data.displayName,
                           @"timeStamp":data.timestamp,
                           @"message":data.message,
                           @"status":@"1"
                           };
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if(error){
        NSLog(@"gagal serialize : %@",error);
    }
    NSString *newStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return newStr;
}

@end
