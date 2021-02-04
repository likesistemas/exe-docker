using System;
using System.Diagnostics;
using System.Threading;

namespace exe_jar
{
    class Program
    {
        static void Main(string[] args) {
            bool instanceCountOne = false;
            using (Mutex mtex = new Mutex(true, "MyRunningApp", out instanceCountOne))
            {
                if (instanceCountOne)
                {
                    var process = new Process()
                    {
                        StartInfo = new ProcessStartInfo
                        {
                            FileName = "java.exe",
                            Arguments = "-jar app.jar",
                            RedirectStandardOutput = true,
                            UseShellExecute = false,
                            CreateNoWindow = true,
                        }
                    };
                    process.Start();

                    mtex.ReleaseMutex();
                }
                else
                {
                    Console.Out.WriteLine("An application instance is already running");
                }
            }            
        }
    }
    
}
