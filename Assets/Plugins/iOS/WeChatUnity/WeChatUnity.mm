// WeChatUnity.mm

#import <Foundation/Foundation.h>
#import "WXApiManager.h"
#import "Utils.h"

#define UNITY_CS_API extern "C"

// 登录
UNITY_CS_API void authLogin(int platformType)
{
    gPlatformType = platformType;
    if (![WXApi isWXAppInstalled]){
        //未安装微信
        NSLog(@"[WeChatUnity] authLogin isWXAppInstalled: false");
        [[WXApiManager sharedManager] OnLoginCompleteCall:WXErrCodeNotInstalled msg:@"wechat_not_installed" code:@""];
        return;
    }

    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo";
    req.state = @"u3d_wechat_auth";
    [WXApi sendReq:req completion:^(bool success){
        if (success) {
            NSLog(@"wechat authLogin sendReq success");
        } else {
            NSLog(@"wechat authLogin sendReq failure");
            [[WXApiManager sharedManager] OnLoginCompleteCall:WXErrCodeSendReqFail msg:@"wechat_sendReq_fail"  code:@""];
        }
    }];

}


