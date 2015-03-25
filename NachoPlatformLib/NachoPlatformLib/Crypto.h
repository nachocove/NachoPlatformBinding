//
//  Crypto.h
//  NachoPlatformLib
//
//  Created by Henry Kwok on 3/24/15.
//  Copyright (c) 2015 Nacho Cove, Inc. All rights reserved.
//

#ifndef NachoPlatformLib_Crypto_h
#define NachoPlatformLib_Crypto_h

@interface Crypto : NSObject

+ (NSString *)certificateToString:(NSString *)certPem;

+ (NSString *)crlToString:(NSString *)crlPem;

+ (NSArray *)crlGetRevoked:(NSString *)crl signingCert:(NSString *)cert;

+ (NSArray *)crlGetRevoked:(NSString *)crl;

@end

#endif
