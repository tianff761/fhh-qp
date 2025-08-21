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
    int errorCode = response.errCode;
     switch (errorCode) {
        case WXSuccess:
            [self OnLoginCompleteCall:YES msg:response.code ?: @""];
            break;
        case WXErrCodeUserCancel:
            [self OnLoginCompleteCall:NO msg:@"UserCancel"];
            break;
        case WXErrCodeAuthDeny:
            [self OnLoginCompleteCall:NO msg:@"AuthDeny"];
            break;
        default:
            [self OnLoginCompleteCall:NO msg:[NSString stringWithFormat:@"error: %d", errorCode]];
            break;
    }
}

-(void)OnLoginCompleteCall:(BOOL)isSuccess msg:(NSString*)msg
{
    sendCallbackMsg(@"WechatLoginCallback", isSuccess, msg);
}


@end
