#import "WXApiManager.h"
#import "Utils.h"

@implementation WXApiManager

// 单例
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)onResp:(BaseResp *)resp {
	// TODO 微信回调，调用微信SDK的sendReq，会回调此方法，登录、分享等都是回调到这里
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
         [self managerDidRecvAuthResponse:authResp];
    }
}

- (void)onReq:(BaseReq *)req {
	// TODO 微信回调，从微信端主动发送过来的请求
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    NSString * message = @"";
     int errorCode = response.errCode;
     switch (errorCode) {
        case WXErrCodeUserCancel:
            message = @"UserCancel";
            break;
        case WXErrCodeAuthDeny:
            message = @"AuthDeny";
            break;
        default:
            break;
    }
    [self OnLoginCompleteCall:response.errCode msg:message code:response.code ?: @""];
}

-(void)OnLoginCompleteCall:(int)errCode msg:(NSString*)message code:(NSString*)code
{
    NSDictionary* receiveMap = @{
        @"code": @(errCode),
        @"msg": message,
        @"platformType": @(gPlatformType),
        @"appId": WeChatAppId,
        @"appSecret": WeChatAppSecret,
        @"appCode": code ?: @""
    };
    sendCallbackMsg(@"WechatLoginCallback", receiveMap);
}


@end
