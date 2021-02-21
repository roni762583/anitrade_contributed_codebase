//+------------------------------------------------------------------+
//|                                Aharon_Bands_on_Volume2stddev.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_ATR.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

/////////////////                      This is just to re-construct BB out of Std. Dev function       ///////////////////////////////


#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
//extern int    AtrPeriod = 5;

//---- buffers
double D[];
double BBu[];
double BBl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="BB_on_Volume("+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Volume");
   SetIndexLabel(1,"Upper");
   SetIndexLabel(2,"Lower");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set values
   for(i=0; i<limit; i++)  {  //volumes
      D[i]=iVolume(NULL, 0, i);
   }
   
   
   for(i=0; i<limit; i++)  {  //  20 Avg. the volumes = middle band
      D[i]=iMAOnArray(D, 0, 20, 0, MODE_SMA, i);
   }
   
   for(i=0; i<limit; i++)  {
   BBu[i] = D[i] + 2*iStdDevOnArray(D, 0, BandsPeriod, 0, MODE_SMA, i);
   BBl[i] = D[i] - 2*iStdDevOnArray(D, 0, BandsPeriod, 0, MODE_SMA, i);
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+