//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_Consecutive.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
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

static double cnt;
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
   short_name="Aharon_Bands_on_Consecutive(" + BandsDeviations + ", " + BandsPeriod + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Consecutive");
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
int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set values

 
   for(i=limit; i>0; i--)  {
     // cnt = 0.0;
      if(Close[i]>Open[i] && Close[i+1]>Open[i+1]) cnt = cnt + 1.0;
      if(Close[i]<Open[i] && Close[i+1]<Open[i+1]) cnt = cnt - 1.0;  
      if( !((Close[i]>Open[i] && Close[i+1]>Open[i+1]) || (Close[i]<Open[i] && Close[i+1]<Open[i+1])) ) cnt = 0.0;
      D[i] = cnt;
   }
  
   
   for(i=limit; i>0; i--)  {
      BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
      BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   return(0);
}
//+------------------------------------------------------------------+