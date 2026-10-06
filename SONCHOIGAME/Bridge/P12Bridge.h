#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface P12Bridge : NSObject
+ (nullable NSData *)changePassword:(NSData *)input oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword outError:(NSError * _Nullable * _Nullable)error;
@end
NS_ASSUME_NONNULL_END
