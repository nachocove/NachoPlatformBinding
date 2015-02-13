using System;

namespace NachoPlatformBinding
{
    public class PlatformProcess
    {
        public PlatformProcess ()
        {
        }

        public static long GetUsedMemory ()
        {
            throw new NotImplementedException ();
        }

        public static int GetCurrentNumberOfFileDescriptors ()
        {
            throw new NotImplementedException ();
        }

        public static int GetCurrentNumberOfInUseFileDescriptors ()
        {
            throw new NotImplementedException ();
        }

        public static string GetFileNameForDescriptor (int fd)
        {
            throw new NotImplementedException ();
        }

        public static int GetNumberOfSystemThreads ()
        {
            throw new NotImplementedException ();
        }

        public static string[] GetStackTrace ()
        {
            throw new NotImplementedException ();
        }
    }
}

