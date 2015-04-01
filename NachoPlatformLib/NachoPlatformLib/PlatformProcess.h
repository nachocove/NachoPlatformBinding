//
//  PlatformProcess.h
//  NachoPlatformLib
//
//  Created by Henry Kwok on 10/9/14.
//  Copyright (c) 2014 Nacho Cove, Inc. All rights reserved.
//

#ifndef NachoPlatformLib_PlatformProcess_h
#define NachoPlatformLib_PlatformProcess_h

@interface PlatformProcess : NSObject

+ (long)getUsedMemory;

+ (int)getCurrentNumberOfFileDescriptors;

+ (int)getCurrentNumberOfInUseFileDescriptors;

+ (NSString *)getFileNameForDescriptor:(int)fd;

+ (int)getNumberOfSystemThreads;

+ (NSString *)getStackTrace;

+ (NSString *)getClassName:(id)obj;

+ (void)scheduleNotification:(NSString *)titleString body:(NSString *)bodyString userInfo:(NSDictionary *)userInfoDict withSound:(BOOL)yesOrNo;

@end


#endif
