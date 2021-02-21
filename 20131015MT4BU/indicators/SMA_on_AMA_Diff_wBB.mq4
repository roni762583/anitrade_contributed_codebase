//sma on ama, diff, bb on diff

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Blue

extern int AMAn        = 10;
extern int AMAnmin     = 2;
extern int AMAnmax     = 5;
extern int maPeriod    = 5;
extern int BBperiod    = 20;
extern int BBdeviation = 2;
extern int BBshft      = 0;

double DiffSMAonAMAandAMA[];
double UBB[];
double LBB[];

static double ama0, ama1, ma, diff, ubb, lbb;

double result = 0.0;

int init()  {
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, DiffSMAonAMAandAMA);
   SetIndexLabel(0, "DiffSMAonAMAandAMA");
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, UBB);
   SetIndexLabel(1, "Upper BB");
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, LBB);
   SetIndexLabel(2, "Lower BB");
   
   string s = "BBdiffSMAonAMAandAMA(" + maPeriod + ")";
   IndicatorShortName(s);
   return(0);
}


int start()   {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars==0) limit=Bars-50; //if first run, give room to prime the ma calc.
   limit=Bars-counted_bars;

   for(i = limit; i>=0; i--)   {
      ama0 = iCustom(Symbol(), 0, "AMA", AMAn, AMAnmin, AMAnmax, 0, i);
      ama1 = iCustom(Symbol(), 0, "AMA", AMAn, AMAnmin, AMAnmax, 0, i+1);
      
      ma  = ((maPeriod-1.0)/maPeriod)*ama1 + (1.0/maPeriod)*ama0;
      
      diff = ama0 - ma;
      DiffSMAonAMAandAMA[i] =  diff;
   }//close for()
   
   for(i = limit; i>=0; i--)   {
      ubb = iBandsOnArray(DiffSMAonAMAandAMA, 0, BBperiod, BBdeviation, BBshft, MODE_UPPER, i);
      lbb = iBandsOnArray(DiffSMAonAMAandAMA, 0, BBperiod, BBdeviation, BBshft, MODE_LOWER, i);
      UBB[i] = ubb;
      //MBB[i] = (ubb+lbb)/2.0;
      LBB[i] = lbb;
   }//close for()
   
   return(0);
}//
//
      //
      //

int deinit()   {

   return(0);
}

