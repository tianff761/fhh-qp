// WXApiManager.h

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXApiManager : NSObject<WXApiDelegate>

+ (instancetype)sharedManager;

- (void)OnLoginCompleteCall:(BOOL)isSuccess msg:(NSString*)msg;

@end