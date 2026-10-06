#import "P12Bridge.h"
#include <openssl/pkcs12.h>
#include <openssl/err.h>

@implementation P12Bridge
+ (NSData *)changePassword:(NSData *)input oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword outError:(NSError * _Nullable * _Nullable)error {
    const unsigned char *cursor = (const unsigned char *)input.bytes;
    PKCS12 *p12 = d2i_PKCS12(NULL, &cursor, (long)input.length);
    if (!p12) { [self fill:error message:@"File P12 không hợp lệ."]; return nil; }

    EVP_PKEY *pkey = NULL; X509 *cert = NULL; STACK_OF(X509) *ca = NULL;
    if (!PKCS12_parse(p12, oldPassword.UTF8String, &pkey, &cert, &ca)) {
        PKCS12_free(p12); [self fill:error message:@"Mật khẩu hiện tại không đúng hoặc P12 không đọc được."]; return nil;
    }
    PKCS12_free(p12);

    PKCS12 *out = PKCS12_create(newPassword.UTF8String, "SONCHOIGAME", pkey, cert, ca, 0, 0, 0, 0, 0);
    EVP_PKEY_free(pkey); X509_free(cert); if (ca) sk_X509_pop_free(ca, X509_free);
    if (!out) { [self fill:error message:@"Không thể tạo P12 mới."]; return nil; }

    int len = i2d_PKCS12(out, NULL);
    if (len <= 0) { PKCS12_free(out); [self fill:error message:@"Không thể mã hóa P12 mới."]; return nil; }
    NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)len];
    unsigned char *ptr = (unsigned char *)data.mutableBytes;
    i2d_PKCS12(out, &ptr); PKCS12_free(out);
    return data;
}
+ (void)fill:(NSError **)error message:(NSString *)message {
    if (error) *error = [NSError errorWithDomain:@"SONCHOIGAME.P12" code:1 userInfo:@{NSLocalizedDescriptionKey:message}];
}
@end
