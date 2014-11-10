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
#import <netinet/in.h>
#import <arpa/inet.h>

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

+ (int)getCurrentNumberOfInUseFileDescriptors
{
    struct stat info;
    int numFds, numInUseFds = 0;
    
    numFds = [PlatformProcess getCurrentNumberOfFileDescriptors];
    for (int fd = 0; fd < numFds; fd++) {
        if (0 == fstat(fd, &info)) {
            numInUseFds++;
        }
    }
    return numInUseFds;
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
    if (S_ISSOCK(info.st_mode)) {
        struct sockaddr_in addr;
        socklen_t addr_len = sizeof(addr);
        int rc = getpeername(fd, (struct sockaddr *)&addr, &addr_len);
        if (0 != rc) {
            snprintf(buf, sizeof(buf), "<socket: destination unknown>");
        } else {
            snprintf(buf, sizeof(buf), "<socket: %s>", inet_ntoa(addr.sin_addr));
        }
        return [NSString stringWithUTF8String:buf];
    }
    if (S_ISFIFO(info.st_mode)) {
        return @"<fifo>";
    }
    
    // Get the file path
    memset(buf, sizeof(buf), 0);
    rc = fcntl(fd, F_GETPATH, buf);
    if (0 != rc) {
        return @"<unknown>";
    }
    
    return [NSString stringWithUTF8String:buf];
}

@end
