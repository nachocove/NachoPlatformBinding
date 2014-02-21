using System;
using MonoTouch.ObjCRuntime;

[assembly: LinkWith ("libNachoPlatformLibSDK.a", LinkTarget.Simulator | LinkTarget.ArmV7, ForceLoad = true)]
