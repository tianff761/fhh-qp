// WeChatUnity.mm

#import <Foundation/Foundation.h>
#import "WXApiManager.h"
#import "Utils.h"

#define UNITY_CS_API extern "C"

static NSString *mWXAppid = nil;

// // 初始化
// UNITY_CS_API void initWeChat(const char* appId, const char* universalLink)
// {
//     NSString *appIdStr = str_c2ns(appId);
//     NSString *ul = str_c2ns(universalLink);
//     NSLog(@"[WeChatUnity] initWeChat appId=%@, universalLink=%@", appIdStr, ul);
//     mWXAppid = appIdStr;
//     [WXApi registerApp:mWXAppid universalLink:ul];
// }


// 登录
UNITY_CS_API void authLogin(int platformType)
{
    if (![WXApi isWXAppInstalled]){
        //未安装微信
        NSLog(@"[WeChatUnity] authLogin isWXAppInstalled: false");
        [[WXApiManager sharedManager] OnLoginCompleteCall:NO msg:@"wechat_not_installed"];
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
            [[WXApiManager sharedManager] OnLoginCompleteCall:NO msg:@"wechat_sendReq_fail"];
        }
    }];

}


