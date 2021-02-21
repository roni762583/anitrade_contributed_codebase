using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System.Collections.Generic;
using System.Linq;

namespace cAlgo.Indicators
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class TopsBotsSR : Indicator
    {
        [Output("Main")]
        public IndicatorDataSeries Result { get; set; }

        Dictionary<string, int> srDic;

        List<double> sRprices;
        // = new List<double>();
        int prevIndex = -10;

        protected override void Initialize()
        {
            sRprices = new List<double>();
            srDic = new Dictionary<string, int>();
        }

        public override void Calculate(int index)
        {
            Print("hi from calc, index=", index);
            ////only run on opening of new bar to prevent recalculating on each tick
            //if (index == prevIndex)
            //{
            //    Print(prevIndex);
            //    return;
            //} 
            prevIndex = index;
            //not using last bar at index since it will not build before comparing to prev. bar  high/lo
            //      if (index - 3 <= 0) return;
            //var ot = MarketSeries.OpenTime[index];
            //var ot1 = MarketSeries.OpenTime[index - 1];
            //var ot2 = MarketSeries.OpenTime[index - 2];
            //var h0 = MarketSeries.High[index];
            var h1 = MarketSeries.High[index - 1];
            var h2 = MarketSeries.High[index - 2];
            var h3 = MarketSeries.High[index - 3];
            //var l0 = MarketSeries.Low[index];
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
            Print("bye from Calculate()");
            if (sRprices.Count > 2)
                UpdateSR();
            //this function processes filling of bins
            //   PrintSRbins();
            //end of Calculate()
        }


        private void UpdateSR()
        {
            Print("hi from UpdateSR()");

        }
            /*
            int counter = 0;
            int binWidth = 10;
            //pips
            double min = 0, max = 0;

            var ct = sRprices.Count;

            //sort
            sRprices.Sort();
            min = sRprices.Min();
            max = sRprices.Max();

            var bin = RoundDownToNearestPrice(min, binWidth);
            Print("ct=", ct, "  min=", min, "  max=", max, "  bin=", bin);

            foreach (var prc in sRprices)
            {
                //looping over s/r prices to populate s/r dictionary
                if (prc < bin)
                    counter++;
                else
                {
                    //   srDic.Add(bin.ToString(), counter);
                    bin += binWidth * Symbol.PipSize;

                    Print("Dictionary: ct=", srDic.Count, "  bin=", bin, "  prev. bin ct=", counter);

                    counter = 0;
                }
            }
            */


                private void PrintSRbins()
        {
            //print dictionary for inspection
            foreach (var pr in srDic)
            {
                Print(pr.Key, " : ", pr.Value);
            }
        }


        private double RoundDownToNearestPrice(double price, int binPips)
        {
            //this function returns the floor price for bin: floor of 'min' (or lower), rounded to 'binPips' pips
            Print("hi from RoundDownToNearestPrice()");
            /*

            Print("Symbol.PipSize=", Symbol.PipSize);
            Print("binPips=", binPips);
            Print("1.0 / (Symbol.PipSize * binPips)=", 1.0 / (Symbol.PipSize * binPips));
            var factor = 1.0 / (Symbol.PipSize * binPips);

            //-----------------------------------------????????????????????otser po!
            Print("buy from RoundDownToNearestPrice");
            return ((int)(price * factor)) / factor;


            */
            return 0.0;
        }

        //class
    }

    public class FeatureIndexPriceStruct
    {
        public int indx { get; set; }
        public int feature { get; set; }
        public double high { get; set; }
        public double low { get; set; }
        public DateTime openTime { get; set; }
    }
    //helper class
}
//namespace



///below is code for top bots
/*
        //get value representing feature 1=top, -1=bot, 2=double, 0=nothin
        int feature = potentialDouble ? 2 : (potentialTop ? 1 : (potentialBot ? -1 : 0));

        //if bar is potential feature, test it
        if (Math.Abs(feature) > 0)
        {
            //instantiate feature object for this latest feature
            latestFeature = new FeatureIndexPriceStruct
            {
                indx = index - 1,
                feature = feature,
                high = h1,
                low = l1,
                openTime = ot1
            };

            //locate feature in list having this bar's open time
            var featureFromList = featuresList.FirstOrDefault(f => f.openTime == ot1);
            if (featureFromList == null)
                //if none found, add latest feature to features list
                featuresList.Add(latestFeature);
            else
            {
                //if located, update its' properties
                featureFromList.feature = latestFeature.feature;
                featureFromList.high = latestFeature.high;
                featureFromList.low = latestFeature.low;
                //featureFromList.openTime = latestFeature.openTime;//already matched on this
            }
//at this point we have the latest feature updated in bar
            //if there exists a previous feature in the list
            if (featuresList.Count >= 2)
            {
                //get it
                prevFeature = featuresList[featuresList.Count - 2];

                //switch-case to compare latest potential feature with the previous one
                switch (latestFeature.feature)
                {
                    //in case this latest feature is potential top
                    case 1:
                        switch (prevFeature.feature)
                        {
                            //in case prev. feature is potential top
                            case 1:
                                if (latestFeature.high > prevFeature.high)
                                {
                                    //the latest feature is more extreme, and will replace prev. feature
                                    featuresList.Remove(prevFeature);
                                    //featuresList.Add(latestFeature);//already added above
                                }
                                else //if(latestFeature.high <= prevFeature.high)
                                {
                                    //latestFeature.feature = 0;
                                    //var nf = new FeatureIndexPriceStruct()
                                    //{
                                    //    feature = latestFeature.feature,
                                    //    high = latestFeature.high,
                                    //    indx = latestFeature.indx,
                                    //    low = latestFeature.low,
                                    //    openTime = latestFeature.openTime
                                    //};
                                    var b = featuresList.Remove(latestFeature);
                                    Print("bool = ", b);
                                    //var temp1 = featuresList.Where(f => f.openTime == MarketSeries.OpenTime[index - 1]).Select(f=>f);
                                    //Print("temp1=",temp1);
                                }
                                break;
                            //in case prev. feature is a bot, add latest feature as top
                            case -1:
                                //featuresList.Add(latestFeature);//already added above
                                break;
                            //in case prev. feature is double (which shouldn't happen)
                            case 2:
                                Print("WTF");
                                break;
                        }
                        break;

                    //in case this latest feature is potential bot
                    case -1:
                        switch (prevFeature.feature)
                        {
                            //in case prev. feature is potential top, write latest feature as bot
                            case 1:
                                //featuresList.Add(latestFeature);//already added above
                                break;
                            //in case prev. feature is a bot, compare and assign the more extreme
                            case -1:
                                if (latestFeature.low < prevFeature.low)
                                {
                                    //the latest feature is more extreme, and will replace prev. feature
                                    featuresList.Remove(prevFeature);
                                    //featuresList.Add(latestFeature);//already added above
                                }
                                else //if(latestFeature.low >= prevFeature.low)
                                {
                                    featuresList.Remove(latestFeature);
                                }
                                break;
                            //in case prev. feature is double (which shouldn't happen)
                            case 2:
                                break;
                        }
                        break;

                    //in case this latest feature is a double
                    case 2:
                        switch (prevFeature.feature)
                        {
                            //in case prev. feature is top, check if it is more extreme than prev., otherwise
                            //assign it as bot.
                            case 1:
                                if (latestFeature.high > prevFeature.high)
                                {//if the high of the latest potential double is higher than the prev. top,
                                    //it will replace it
                                    var pot = prevFeature.openTime;
                                    featuresList.RemoveAll(f=>f==prevFeature);
                                    latestFeature.feature = 1;
                                    Print("double assigned to top (deleted prev. top at ", pot,") at ", latestFeature.openTime);
                                }
                                else
                                {//if it is not a more extreme top, latest potential double will be a bot.
                                    latestFeature.feature = -1;
                                    Print("double assigned as bot");
                                }
                                //featuresList.Add(latestFeature);//already added above
                                break;
                            //in case prev. feature is a bot, check if it is more extreme than prev., otherwise
                            //assign it as top
                            case -1:
                                if (latestFeature.low < prevFeature.low)
                                {//if the low of the latest potential double is lower than the prev. bot,
                                    //it will replace it
                                    var pot = prevFeature.openTime;
                                    featuresList.Remove(prevFeature);
                                    latestFeature.feature = -1;
                                    Print("double assigned to bot (deleted prev. bot at ",pot,") at ", latestFeature.openTime);
                                }
                                else
                                {//if it is not a more extreme bot, latest potential double will be a top
                                    latestFeature.feature = 1;
                                    Print("double assigned as top");
                                }
                                //featuresList.Add(latestFeature);//already added above
                                break;
                            //in case prev. feature is double (which shouldn't happen)
                            case 2:
                                Print("WTF");
                                break;
                        }
                        break;
                }
                //switch-case on feature (outter)
            }
            //if (featuresList.Count >= 1)
        }
        //if (Math.Abs(feature) > 0)


        //populate indicator result arr., and prices list with latest feature
        //count of features in list
        var ct = featuresList.Count;
        FeatureIndexPriceStruct feat = null;

        //get last feature
        if (ct > 1)
            feat = featuresList[ct - 1];
        if (feat != null)
        {
            Result[index - 1] = 0;
            Result[feat.indx] = feat.feature;
        }
        */
//////////////////////// to this point indicator shows somewhat ok //////////////////////
/*
//calculate frequency distribution of feature prices for S/R
//zero out list
prices.Clear();

//populate feature price list
foreach (var ftr in featuresList)
{
if (ftr.feature == 1)
prices.Add(ftr.high);
if (ftr.feature == -1)
prices.Add(ftr.low);
}

double min = 0, max = 0;

//instantiate dictionary for bins count (string better key than double)
Dictionary<string, int> binsDictionary = new Dictionary<string, int>();

if (prices != null && prices.Count > 50)
{//if cond. is to prevent exceptions on empty collection, etc.
//sort list
//Print("prc ct ", prices.Count);
prices.Sort();
min = prices[0];
max = prices[prices.Count - 1];
}//if(prices!=null

//width of bins in pips, later to possibly get as external parameter
int binPips = 10;

//initial bin ceiling level
double binCeiling = RoundDownToNearestPrice(min, binPips);

//add first bin
var key = binCeiling.ToString();
binsDictionary.Add(key, 0);

//loop over prices list
foreach (var prc in prices)
{
//if current price is less than ceiling, increment bin counter
if (prc < binCeiling)
binsDictionary[key]++;
else
{
//if price doesn't 'fit' in current bin, add new bin to include it
binCeiling += binPips * Symbol.PipSize;
key = binCeiling.ToString();
//increment new bin to 1 for current price
binsDictionary.Add(key, 1);
}
}//foreach


//print dictionary for inspection
foreach (var pair in binsDictionary)
{
Console.WriteLine("Price Ceiling: {0},   Count: {1}", pair.Key, pair.Value);
}
*/
