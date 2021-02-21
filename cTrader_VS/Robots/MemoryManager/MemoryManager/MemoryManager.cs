using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using cAlgo.API;

namespace MoneyBiz.TraderBots.Bots
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.FullAccess)]
    public class MemoryManager : Robot
    {
        private long _lastFreeTime;
        private long _lastReclaimed;

        [Parameter("Reclaim Period (seconds)", DefaultValue = 60, MinValue = 10, Step = 10)]
        public int ReclaimPeriod { get; set; }

        protected override void OnStart()
        {
            if (Environment.OSVersion.Platform != PlatformID.Win32NT)
            {
                Print("Memory Manager: Platform not supported.");
                Stop();

                return;
            }

            var stats = Free();

            DrawStats(stats);
        }

        protected override void OnTick()
        {
            var stats = Free();

            DrawStats(stats);
        }

        public void DrawStats(Tuple<long, long> stats)
        {
            if (stats != null)
            {
                _lastReclaimed = stats.Item1 - stats.Item2;
            }

            var currentWorkingSet = BytesToMegabytes(Environment.WorkingSet);
            var lastReclaimed = BytesToMegabytes(_lastReclaimed);
            var timeSpan = TimeSpan.FromTicks(DateTime.Now.Ticks - _lastFreeTime);

            var text = string.Format("Working Set: {1:N2} MB{0}Last Reclaimed: {2:N2} MB ({3:N0} s)", Environment.NewLine, currentWorkingSet, lastReclaimed, timeSpan.TotalSeconds);

            ChartObjects.DrawText("MemStats", text, StaticPosition.TopLeft, Colors.Orange);
        }

        private static double BytesToMegabytes(long value)
        {
            return (double)value / (1024 * 1024);
        }

        private Tuple<long, long> Free()
        {
            if (DateTime.Now.Ticks - _lastFreeTime <= TimeSpan.FromSeconds(ReclaimPeriod).Ticks)
            {
                return null;
            }

            Tuple<long, long> workingSets = null;

            try
            {
                using (var process = Process.GetCurrentProcess())
                {
                    var before = Environment.WorkingSet;

                    if (Environment.Is64BitProcess)
                    {
                        SetProcessWorkingSetSize64(process.Handle, -1, -1);
                    }
                    else
                    {
                        SetProcessWorkingSetSize32(process.Handle, -1, -1);
                    }

                    var after = Environment.WorkingSet;

                    workingSets = Tuple.Create(before, after);
                }

                _lastFreeTime = DateTime.Now.Ticks;

                Print("Memory Manager: Reclaimed {0:N0} bytes.", workingSets.Item1 - workingSets.Item2);
            } catch (Exception ex)
            {
                Print("Memory Manager: " + ex);
            }

            return workingSets;
        }

        [DllImport("KERNEL32.DLL", EntryPoint = "SetProcessWorkingSetSize", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
        static internal extern bool SetProcessWorkingSetSize32(IntPtr pProcess, int dwMinimumWorkingSetSize, int dwMaximumWorkingSetSize);

        [DllImport("KERNEL32.DLL", EntryPoint = "SetProcessWorkingSetSize", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
        static internal extern bool SetProcessWorkingSetSize64(IntPtr pProcess, long dwMinimumWorkingSetSize, long dwMaximumWorkingSetSize);
    }
}
