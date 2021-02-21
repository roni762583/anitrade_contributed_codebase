using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System.Collections.Generic;
using System.Linq;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class aSR : Indicator
    {
        [Parameter(DefaultValue = 0.0)]
        public double Parameter { get; set; }

        [Output("Main", Color = Colors.Red)]
        public IndicatorDataSeries Result { get; set; }

        List<double> sRprices;
        Dictionary<string, int> srDic;
        int prevIndex = 10;
        double prev;
        double bin = 0;
        //binWidth in pips
        int binWidth = 10;
        double binIncrement;

        protected override void Initialize()
        {
            sRprices = new List<double>();
            srDic = new Dictionary<string, int>();
            prev = 0.0;
            binIncrement = binWidth * Symbol.PipSize;
        }

        public override void Calculate(int index)
        {
            //Print("hi from calc, index=", index);
            ////only run on opening of new bar to prevent recalculating on each tick
            if (index == prevIndex)
            {
                return;
            }
            prevIndex = index;

            //not using last bar at index since it will not build before comparing to prev. bar  high/lo
            if (index - 3 <= 0)
                return;

            var h1 = MarketSeries.High[index - 1];
            var h2 = MarketSeries.High[index - 2];
            var h3 = MarketSeries.High[index - 3];

            var l1 = MarketSeries.Low[index - 1];
            var l2 = MarketSeries.Low[index - 2];
            var l3 = MarketSeries.Low[index - 3];

            bool potentialTop = (h2 > h1 && h2 > h3) ? true : false;
            bool potentialBot = (l2 < l1 && l2 < l3) ? true : false;
            bool potentialDouble = potentialBot && potentialTop;

            if (potentialDouble)
            {
                sRprices.Add(h2);
                sRprices.Add(l2);
            }
            else if (potentialTop)
            {
                sRprices.Add(h2);
            }
            else if (potentialBot)
            {
                sRprices.Add(l2);
            }

            if (sRprices.Count > 2)
            {
                UpdateSR();
                Result[index] = sRprices.Count;
            }
            // var dominantKey = srDic.Keys.Where(k => double.Parse(k) > MarketSeries.Close[index]);

            if (srDic.Count > 0)
            {
                //double res;
                // if (double.TryParse(srDic.Last().Key, out res))
                //Print(res);
                Colors clr = GetSrAbove(Symbol.Bid);

            }
            //only print dictionary on first tick of new and bars having only one tick
            if (MarketSeries.TickVolume.LastValue == 1)
                PrintSrDictionary();
        }

        private void PrintSrDictionary()
        {
            foreach (var pair in srDic)
            {
                Print(pair.Key, " : ", pair.Value);
            }
        }

        private Colors GetSrAbove(double price)
        {
            //  function returns colors: Red, Yellow, Green, Blue corresponding to:
            //  >75th, >50th, >25th, <25th percentile ranking of count in S/R dictionary 
            //  of the bin just above parameter price

            //find bin above price
            srDic.Keys.
            //get percentile for count at bin

            //return corresponding color
            //temp
            return Colors.Black;
        }

        private void UpdateSR()
        {
            int counter = 0;

            //pips
            double min = 0, max = 0;
            int ct = sRprices.Count;
            //sort
            sRprices.Sort();
            min = sRprices.Min();
            max = sRprices.Max();
            //

            if (bin == 0)
                bin = RoundDownToNearestPrice(min, binWidth);
            //checks good
            //Print("ct=", ct, "  min=", min, "  max=", max, "  bin=", bin);

            foreach (var prc in sRprices)
            {
                //looping over s/r prices to populate s/r dictionary
                if (prc < bin)
                    counter++;
                else
                {
                    bin += binIncrement;

                    var binStr = GetBinString(bin);

                    //only add non zero count bins
                    if (!srDic.ContainsKey(binStr) && counter > 0)
                    {
                        srDic.Add(binStr, counter);
                        //Print("current bin[", binStr, "] count = ", counter);
                    }
                    else
                    {
                        //Print("dictionary already has key ", binStr, " whos count=, srDic[binStr]", "  counter =", counter);
                        //Print("Dictionary: ct=", srDic.Count, "  bin=", bin, "  prev. bin ct=", counter, " binStr=", binStr);
                    }
                    counter = 0;
                }
            }
            //UpdateSR()
        }


        private string GetBinString(double bin)
        {
            //number of decimals quoted
            var len = GetDigits();
            //split off the decimal portion of bin param            
            var sArr = bin.ToString().Split('.');
            //address the decimal portion, add some zeroes so length is sufficient, and limit to len digits
            var decStr = (sArr[sArr.Length - 1] + "0000").Substring(0, len);

            return sArr[0].ToString() + "." + decStr;
            //return bin as string limited to bin precision digits
        }

        private int GetDigits()
        {
            return (int)(-1 * Math.Log(Symbol.TickSize) / Math.Log(10));
        }

        private double RoundDownToNearestPrice(double price, int binPips)
        {
            //this function returns the floor price for bin: floor of 'min' (or lower), rounded to 'binPips' pips
            var factor = 1.0 / (Symbol.PipSize * binPips);
            factor = ((int)(price * factor)) / factor;
            return factor;
            //end RoundDownToNearestPrice()
        }
        // end class

    }
    //end namespace
}
