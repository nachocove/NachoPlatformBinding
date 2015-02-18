using System;
using ObjCRuntime;

[assembly: LinkWith ("libNachoPlatformLibSDK.a", LinkTarget.Simulator | LinkTarget.Simulator64 | LinkTarget.ArmV7 | LinkTarget.Arm64, ForceLoad = true)]
