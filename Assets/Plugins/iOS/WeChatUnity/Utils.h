#import <Foundation/Foundation.h>

NSString * str_c2ns(const char *s);
NSString * dictToJson(NSDictionary *dict);
void sendCallbackMsg(NSString *funcName, NSDictionary* receiveMap);

extern NSString * const WeChatAppId;
extern NSString * const WeChatAppSecret;
extern NSString * const WeChatUL;

extern int const WXErrCodeNotInstalled;
extern int const WXErrCodeSendReqFail;

extern int gPlatformType;



