#import <Foundation/Foundation.h>

NSString * str_c2ns(const char *s);
NSString * dictToJson(NSDictionary *dict);
void sendCallbackMsg(NSString *funcName, BOOL isSuccess, NSString *code);


