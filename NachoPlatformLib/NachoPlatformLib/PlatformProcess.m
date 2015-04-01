//
//  PlatformProcess.m
//  NachoPlatformLib
//
//  Created by Henry Kwok on 10/9/14.
//  Copyright (c) 2014 Nacho Cove, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/param.h>
#import <sys/stat.h>
#import "mach/mach.h"
#import "PlatformProcess.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import <execinfo.h>

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
        char sock_buf[2048];
        struct sockaddr *addr = (struct sockaddr *)sock_buf;
        socklen_t addr_len = sizeof(sock_buf);
        int rc = getpeername(fd, addr, &addr_len);
        if (0 != rc) {
            snprintf(buf, sizeof(sock_buf), "<socket: destination unknown>");
        } else {
            switch (addr->sa_family) {
                case AF_INET: {
                    struct sockaddr_in *addr4 = (struct sockaddr_in *)sock_buf;
                    char addr_buf[INET_ADDRSTRLEN+1];
                    memset(addr_buf, 0, sizeof(addr_buf));
                    const char *addr_str = inet_ntop(AF_INET, &addr4->sin_addr.s_addr, addr_buf, sizeof(addr_buf));
                    if (addr_str) {
                        snprintf(buf, sizeof(buf), "<ipv4 socket: %s>", addr_str);
                    } else {
                        snprintf(buf, sizeof(buf), "<ipv4 socket: unknown address (errno=%d)", errno);
                    }
                    break;
                }
                case AF_INET6: {
                    struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)sock_buf;
                    char addr6_buf[INET6_ADDRSTRLEN+1];
                    memset(addr6_buf, 0, sizeof(addr6_buf));
                    const char *addr_str = inet_ntop(AF_INET6, &addr6->sin6_addr, addr6_buf, sizeof(addr6_buf));
                    if (addr_str) {
                        snprintf(buf, sizeof(buf), "<ipv6 socket: %s>", addr_str);
                    } else {
                        snprintf(buf, sizeof(buf), "<ipv6 socket: unknown address (errno=%d)", errno);
                    }
                    break;
                }
                case AF_UNIX: {
                    // In Xcode 6, sockaddr_un disappears. So, we need to directly
                    // print out the 2nd byte of the sockaddr where the file path starts
                    snprintf(buf, sizeof(buf), "<unix socket: %s>", &sock_buf[2]);
                    break;
                }
                case AF_SYSTEM: {
                    snprintf(buf, sizeof(buf), "<system socket>");
                    break;
                }
                default: {
                    snprintf(buf, sizeof(buf), "<unknown socket: af=%d>", addr->sa_family);
                    break;
                }
            }
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

+ (int) getNumberOfSystemThreads
{
    mach_msg_type_number_t count;
    thread_act_array_t thread_list;
    if (KERN_SUCCESS != task_threads(mach_task_self(), &thread_list, &count)) {
        return -1;
    }
    return count;
}

+ (NSArray *) getStackTrace
{
    void* callstack[128];
    int i, numFrames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, numFrames);
    NSMutableArray *stackFrames = [NSMutableArray arrayWithCapacity:numFrames];
    for (i = 0; i < numFrames; ++i) {
        NSString *frame = [NSString stringWithUTF8String:strs[i]];
        [stackFrames setObject:frame atIndexedSubscript:i];
    }
    free(strs);
    return stackFrames;
}

+ (NSString *) getClassName:(id)obj
{
    return NSStringFromClass([obj class]);
}

+ (void)scheduleNotification:(NSString *)alertTitle body:(NSString *)alertBody userInfo:(NSDictionary *)dict withSound:(BOOL)yesOrNo
{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertTitle = alertTitle;
    notif.alertBody = alertBody;
    notif.userInfo = dict;
    if (yesOrNo) {
        notif.soundName = UILocalNotificationDefaultSoundName;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

@end
