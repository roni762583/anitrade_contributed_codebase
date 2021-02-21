using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None, ScalePrecision = 15)]
    public class LRF_PSAR_Trend : Indicator
    {
        [Parameter()]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 10)]
        public int LRFperiod { get; set; }

        [Parameter(DefaultValue = 14)]
        public int MAperiod { get; set; }

        [Parameter(DefaultValue = 500)]
        public int ZSperiod { get; set; }

        [Parameter(DefaultValue = 0.75)]
        public double HiThld { get; set; }

        [Parameter(DefaultValue = -0.75)]
        public double LoThld { get; set; }

        [Parameter("min accumulation factor", DefaultValue = 0.02)]
        public double minAF { get; set; }

        [Parameter("max accumulation factor", DefaultValue = 0.2)]
        public double maxAF { get; set; }


        [Output("Entry_Sig", Color = Colors.White, PlotType = PlotType.Points)]
        public IndicatorDataSeries LRFthld { get; set; }
        [Output("Exit_Sig", Color = Colors.Red, PlotType = PlotType.Points)]
        public IndicatorDataSeries PSARdir { get; set; }
        [Output("Composite Signal", Color = Colors.Blue, PlotType = PlotType.Histogram)]
        public IndicatorDataSeries Signal { get; set; }

        private LinearRegressionForecast lrf;
        private MovingAverage ma;
        private IndicatorDataSeries diff;
        private TimeSeriesMovingAverage zsma;
        private StandardDeviation zsstddev;
        private ParabolicSAR psar;

        protected override void Initialize()
        {
            lrf = Indicators.LinearRegressionForecast(Source, LRFperiod);
            ma = Indicators.SimpleMovingAverage(lrf.Result, MAperiod);

            psar = Indicators.ParabolicSAR(minAF, maxAF);

            diff = CreateDataSeries();
            zsma = Indicators.TimeSeriesMovingAverage(diff, ZSperiod);
            zsstddev = Indicators.StandardDeviation(diff, ZSperiod, MovingAverageType.Simple);
        }

        public override void Calculate(int index)
        {
            var sma = ma.Result[index];
            var slrf = lrf.Result[index];
            diff[index] = slrf - sma;
            var ind = (diff[index] - zsma.Result[index]) / zsstddev.Result[index];

            LRFthld[index] = ind >= HiThld ? 1.0 : (ind <= LoThld ? -1.0 : 0);

            PSARdir[index] = psar.Result[index] > MarketSeries.High[index] ? -1.0 : 1.0;

            //if LRFthld flipped
            if ((LRFthld[index - 1] <= 0 && LRFthld[index] == 1.0) || (LRFthld[index - 1] >= 0 && LRFthld[index] == -1.0))
            {
                //...and in agreement w/ PSAR
                if (PSARdir[index] == LRFthld[index])
                    Signal[index] = PSARdir[index];
            }
            else if ((PSARdir[index - 1] < 0 && PSARdir[index] > 0) || (PSARdir[index - 1] > 0 && PSARdir[index] < 0))
            {
                //else if PSAR flipped, signal zeroed
                Signal[index] = 0.0;
            }
            else
                Signal[index] = Signal[index - 1];
            //else retain state

        }
    }
}
