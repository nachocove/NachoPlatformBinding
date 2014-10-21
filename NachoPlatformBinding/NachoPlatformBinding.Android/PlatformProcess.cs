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

        public static string GetFileNameForDescriptor (int fd)
        {
            throw new NotImplementedException ();
        }
	}
}

