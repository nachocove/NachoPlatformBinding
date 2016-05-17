//
//  Crypto.m
//  NachoPlatformLib
//
//  Created by Henry Kwok on 3/24/15.
//  Copyright (c) 2015 Nacho Cove, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Crypto.h"
#import "crypto_openssl.h"

@implementation Crypto

+ (NSString *)certificateToString:(NSString *)certPem
{
    if (nil == certPem) {
        return nil;
    }
    const char *pem = [certPem UTF8String];
    char *desc = openssl_cert_to_string(pem);
    if (NULL == desc) {
        return nil;
    }
    NSString *retval = [NSString stringWithUTF8String:desc];
    free(desc);
    return retval;
}

+ (NSString *)crlToString:(NSString *)crlPem
{
    if (nil == crlPem) {
        return nil;
    }
    const char *pem = [crlPem UTF8String];
    char *desc = openssl_crl_to_string(pem);
    if (NULL == desc) {
        return nil;
    }
    NSString *retval = [NSString stringWithUTF8String:desc];
    free(desc);
    return retval;
}

+ (NSArray *)crlGetRevoked:(NSString *)crl signingCert:(NSString *)cert
{
    const char *crlPem = NULL;
    const char *certPem =  NULL;
    if (nil != crl) {
        crlPem = [crl UTF8String];
    }
    if (nil != cert) {
        certPem = [cert UTF8String];
    }
    const char *reason = NULL;
    char **snList = openssl_crl_get_revoked(crlPem, certPem, &reason);
    char **origSnList = snList;
    if (NULL == snList) {
        NSLog(@"%s", reason);
        return nil;
    }
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    while (NULL != *snList) {
        [retval addObject:[NSString stringWithUTF8String:*snList]];
        free(*snList);
        *snList = NULL;
        snList++;
    }
    free(origSnList);
    return retval;
}

+ (NSArray *)crlGetRevoked:(NSString *)crl
{
    return [Crypto crlGetRevoked:crl signingCert:nil];
}

@end
