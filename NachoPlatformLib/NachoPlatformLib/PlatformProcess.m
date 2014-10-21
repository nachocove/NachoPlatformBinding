//
//  PlatformProcess.m
//  NachoPlatformLib
//
//  Created by Henry Kwok on 10/9/14.
//  Copyright (c) 2014 Nacho Cove, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/param.h>
#import <sys/stat.h>
#import "mach/mach.h"
#import "PlatformProcess.h"

@implementation PlatformProcess

+ (long)getUsedMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    vm_size_t process_size = (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
    return process_size;
}

+ (int)getCurrentNumberOfFileDescriptors
{
    struct rlimit info;
    int rc = getrlimit(RLIMIT_NOFILE, &info);
    if (0 != rc) {
        return -1;
    }
    return (int)info.rlim_cur;
}

+ (NSString *)getFileNameForDescriptor:(int)fd
{
    int rc;
    char buf[MAXPATHLEN + 1];
    struct stat info;

    // Make sure that the fd exists
    if (0 != fstat(fd, &info)) {
        return nil;
    }
    
    // Get the file path
    memset(buf, sizeof(buf), 0);
    rc = fcntl(fd, F_GETPATH, buf);
    if (0 != rc) {
        return nil;
    }
    
    return [NSString stringWithUTF8String:buf];
}

@end
