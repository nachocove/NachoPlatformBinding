//
//  Crypto.m
//  NachoPlatformLib
//
//  Created by Henry Kwok on 3/24/15.
//  Copyright (c) 2015 Nacho Cove, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Crypto.h"

@implementation Crypto

+ (NSString *)certificateToString:(NSString *)certPem:(NSString *)certPem
{
    NSLog(@"dumpCertificate");
    if (nil == certPem) {
        return nil;
    }
    
    // Read in the certifcate in PEM
    const char *pem = [certPem UTF8String];
}

+ (NSString *)crlToString:(NSString *)crlPem;
{
    NSLog(@"dumpCrl");
    if (nil == crlPem) {
        return;
    }
    
    // Read in the CRL in PEM
    
    // Print it out
}

+ (BOOL)verifyCertificate:(NSArray *)certPem pinnedCertificate:(NSString *)rootPem crls:(NSArray *)crlPem
{
    return true;
}

@end
