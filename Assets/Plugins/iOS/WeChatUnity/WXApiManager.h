// WXApiManager.h

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXApiManager : NSObject<WXApiDelegate>

+ (instancetype)sharedManager;

- (void)OnLoginCompleteCall:(int)errCode msg:(NSString*)message code:(NSString*)code;

@end
