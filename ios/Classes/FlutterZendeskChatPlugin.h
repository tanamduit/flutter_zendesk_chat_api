#import <Flutter/Flutter.h>

static FlutterMethodChannel *channel;
@interface FlutterZendeskChatPlugin : NSObject<FlutterPlugin>

@property(nonatomic, assign) BOOL isFirstTime;
@property(nonatomic, assign) NSString *lastId;
    
@end
