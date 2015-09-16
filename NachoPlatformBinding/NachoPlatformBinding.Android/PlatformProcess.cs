using System;
using System.IO;
using Android.OS;
using System.Runtime.InteropServices;


namespace NachoPlatformBinding
{
    public class PlatformProcess
    {
        public PlatformProcess ()
        {
        }

        protected static int myPid ()
        {
            return Process.MyPid ();
        }

        protected static string SearchProcStatus (string target)
        {
            var path = String.Format ("/proc/{0}/status", myPid ());

            string line;
            using (System.IO.StreamReader file = new System.IO.StreamReader (path)) {
                while ((line = file.ReadLine ()) != null) {
                    if (line.StartsWith (target, StringComparison.OrdinalIgnoreCase)) {
                        if (target.Length < line.Length) {
                            var value = line.Substring (target.Length);
                            return value.Trim ();
                        } else {
                            return "";
                        }
                    }
                }
            }
            return null;
        }

        public static long GetUsedMemory ()
        {
            return Java.Lang.Runtime.GetRuntime ().TotalMemory ();
        }

        public static int GetCurrentNumberOfFileDescriptors ()
        {
            var value = SearchProcStatus ("FDSize:");
            if (String.IsNullOrEmpty (value)) {
                Console.WriteLine ("GetCurrentNumberOfFileDescriptors: cannot find number of file descriptors.");
                return 0;
            }
            int n;
            if (int.TryParse (value, out n)) {
                return n;
            }
            return 0;
        }

        public static int GetCurrentNumberOfInUseFileDescriptors ()
        {
            var path = String.Format ("/proc/{0}/fd", myPid ());
            var dir = new DirectoryInfo (path);
            try {
                return dir.GetFileSystemInfos ().Length;
            } catch (Exception e) {
                Console.WriteLine ("GetCurrentNumberOfInUseFileDescriptors: error accessing file descriptors {0}", e);
                return 0;
            }
        }


        [DllImport ("libc")]
        private static extern int readlink(string path, byte[] buffer, int buflen);

        public static string readlink(string path) {
            byte[] buf = new byte[512];
            int ret = readlink(path, buf, buf.Length);
            if (ret == -1) return null;
            char[] cbuf = new char[512];
            int chars = System.Text.Encoding.Default.GetChars(buf, 0, ret, cbuf, 0);
            return new String(cbuf, 0, chars);
        }

        public static string GetFileNameForDescriptor (int fd)
        {
            var path = String.Format ("/proc/{0}/fd/{1}", myPid (), fd);
            try {
                var filename = readlink (path);
                return filename;
            } catch (Exception e) {
                Console.WriteLine ("GetFileNameForDescriptor: error reading symbolic link {0}", e);
                return "";
            }
        }

        public static int GetNumberOfSystemThreads ()
        {
            var value = SearchProcStatus ("Threads:");
            if (String.IsNullOrEmpty (value)) {
                Console.WriteLine ("GetNumberOfSystemThreads: cannot find number of threads.");
                return 0;
            }
            int n;
            if (int.TryParse (value, out n)) {
                return n;
            }
            return 0;
        }

        public static string[] GetStackTrace ()
        {
            var stacktrace = System.Environment.StackTrace;
            return stacktrace.Split (new string[] { System.Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
        }
    }
}

