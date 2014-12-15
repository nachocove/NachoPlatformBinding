// # Copyright (C) 2014 Nacho Cove, Inc. All rights reserved.
//
using System;
using System.Drawing;
using MonoTouch.ObjCRuntime;
using MonoTouch.Foundation;
using MonoTouch.UIKit;

namespace NachoPlatformBinding
{
    delegate void ReachabilityBlock (Reachability reachability);

    [BaseType (typeof(NSObject))]
    interface Reachability
    {
        [Static, Export ("reachabilityForInternetConnection")]
        Reachability ReachabilityForInternetConnection ();

        [Export ("reachableBlock")]
        ReachabilityBlock ReachableBlock { get; set; }

        [Export ("unreachableBlock")]
        ReachabilityBlock UnreachableBlock { get; set; }

        [Export ("isReachable")]
        bool IsReachable ();

        [Export ("isReachableViaWiFi")]
        bool IsReachableViaWiFi ();

        [Export ("startNotifier")]
        void StartNotifier ();

        [Export ("stopNotifier")]
        void StopNotifier ();
    }

    [BaseType (typeof(NSObject))]
    interface PlatformProcess
    {
        [Static, Export ("getUsedMemory")]
        long GetUsedMemory ();

        [Static, Export ("getCurrentNumberOfFileDescriptors")]
        int GetCurrentNumberOfFileDescriptors ();

        [Static, Export ("getCurrentNumberOfInUseFileDescriptors")]
        int GetCurrentNumberOfInUseFileDescriptors ();

        [Static, Export ("getFileNameForDescriptor:")]
        string GetFileNameForDescriptor (int fd);

        [Static, Export ("getNumberOfSystemThreads")]
        int GetNumberOfSystemThreads ();
    }
}

