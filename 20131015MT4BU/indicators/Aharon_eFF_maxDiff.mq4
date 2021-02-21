//      Aharon_FF_maxDiff.mq4 copyright
// this plots the difference between FIRMA_FULL on Highs and FIRMA_FULL on Lows
//+------------------------------------------------------------------+
//|                                             FIRMA_MA_MA_Full.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           Aharon_FIRMA_MA_MA.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 White

//---- external parameters
/*///////////////////              Time Frame Options  /////////////////////////
PERIOD_M1 1 minute. 
PERIOD_M5 5 5 minutes. 
PERIOD_M15 15 15 minutes. 
PERIOD_M30 30 30 minutes. 
PERIOD_H1 60 1 hour. 
PERIOD_H4 240 4 hour. 
PERIOD_D1 1440 Daily. 
PERIOD_W1 10080 Weekly. 
PERIOD_MN1 43200 Monthly. 
0 (zero) 0 Timeframe  
//////////////////////////////////////////////////////////////////////////////*/
//default values correspond to tested values

extern int    Periods = 4;
extern int    Taps   = 21;     //must be odd number
extern int    Window   = 4;
extern int    BandsPeriod = 20;
extern int    Deviations  = 2;

//---- buffers
double FF_maxDiff[];  //difference between firma full on highs and firma full on lows
double UBB[];   //Upper band
double LBB[];   //Lower band
//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(3);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "FF_maxDiff(" + Periods + ", " + Taps + ", " + Window + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"FF_maxDiff");
   SetIndexLabel(1,"UBB");
   SetIndexLabel(2,"LBB");
                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   
   SetIndexBuffer(0,FF_maxDiff);
   SetIndexBuffer(1,UBB);
   SetIndexBuffer(2,LBB);
   
   return(0);
}



//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}



//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
int start()   {

   int limit, i;
   int counted_bars=IndicatorCounted();
                                                            //---- check for possible errors
   if(counted_bars<0) return(-1);
                                                            //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
                                                             // Set values
   for(i=0; i<limit; i++)  {
      FF_maxDiff[i]= iCustom(NULL, 0, "Aharon_eFF_H", 
                             Periods, Taps, Window,   
                             2, i) -  // -
                                      //mode 2 is firma full,  i is shift
                                      // extern int  Periods = 4;   // 1/(2*Periods) sets the filter bandwidth
                                      // extern int  Taps    = 21;  // must be an odd number
                                      // extern int  Window  = 4;   // selects windowing function
                     iCustom(NULL, 0, "Aharon_eFF_L", 
                             Periods, Taps, Window,   
                             2, i) ;
   }
   
   for(i=0; i<limit; i++)  {
      UBB[i] = iBandsOnArray(FF_maxDiff, 0, BandsPeriod, Deviations, 0, MODE_UPPER, i);
   }
   
   for(i=0; i<limit; i++)  {
      LBB[i] = iBandsOnArray(FF_maxDiff, 0, BandsPeriod, Deviations, 0, MODE_LOWER, i);
   }
          
   return(0);

}


