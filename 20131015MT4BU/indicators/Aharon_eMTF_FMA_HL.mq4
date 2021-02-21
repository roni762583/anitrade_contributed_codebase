//+------------------------------------------------------------------+
//|                                           Aharon_eMTF_FMA_HL.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Purple
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Blue



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
//Initial values correspond to tested values
extern int    TF1 = 1;
extern int    TF2 = 5;
extern int    TF3 = 15;
extern int    TF4 = 60;

extern int    Period1 =   4;
extern int    Taps1   =   21;  //must be odd number
extern int    Window1   = 4;


double Slope(double 







//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
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
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      FIRMA[i]= iCustom(NULL, TF1, "Aharon_eFF_H"
   }
   return(0);
}
//+------------------------------------------------------------------+