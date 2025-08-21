#import "Utils.h"

extern "C" void UnitySendMessage(const char* obj, const char* method, const char* msg);

NSString * const WeChatAppId = @"wx8ed80c323f9d13cc";
NSString * const WeChatAppSecret = @"80e091cdf7e7ab4e7e4994b4afe9346d";
NSString * const WeChatUL = @"https://web.xiaougame.org/wx_redirect/";

int const WXErrCodeNotInstalled = 3;
int const WXErrCodeSendReqFail = 99;

int gPlatformType = 0;

NSString * str_c2ns(const char *s)
{
    if (s)
        return [NSString stringWithUTF8String: s];
    else
        return [NSString stringWithUTF8String: ""];
}

NSString * dictToJson(NSDictionary *dict)
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"PluginUtils: dictToJson - 输入参数无效");
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        NSLog(@"PluginUtils: dictToJson - JSON序列化失败: %@", error.localizedDescription);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        NSLog(@"PluginUtils: dictToJson - 无法创建JSON字符串");
        return nil;
    }
    return jsonString;
}

void sendCallbackMsg(NSString *method, NSDictionary* receiveMap)
{
    // NSString *successStr = isSuccess ? @"true" : @"false";
    // NSDictionary* receiveMap = @{@"isSuccess": successStr, @"code": code ?: @""};
    NSString* jsonStr = dictToJson(receiveMap);
    UnitySendMessage("IosCallBack", [method UTF8String], [jsonStr UTF8String]);
}


