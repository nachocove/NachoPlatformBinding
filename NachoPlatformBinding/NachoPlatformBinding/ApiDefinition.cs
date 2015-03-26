// # Copyright (C) 2014 Nacho Cove, Inc. All rights reserved.
//
using System;
using System.Drawing;
using ObjCRuntime;
using Foundation;
using UIKit;

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

        [Static, Export ("getStackTrace")]
        string[] GetStackTrace ();
    }

    [BaseType (typeof(NSObject))]
    interface Crypto
    {
        [Static, Export ("certificateToString:")]
        string CertificateToString (string pem);

        [Static, Export ("crlToString:")]
        string CrlToString (string pem);

        [Static, Export ("crlGetRevoked:signingCert:")]
        string[] CrlGetRevoked (string crl, string signingCert);

        [Static, Export ("crlGetRevoked:")]
        string[] CrlGetRevoked (string crl);
    }
}

