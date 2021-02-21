//+------------------------------------------------------------------+
//|                                                      AZ_gFIR.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_separate_window

// Global Scope Variables


//---- buffers
double S[];




//---- input parameters
extern int       Taps=21;
extern int       Windowing=1;
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
int start()
  {
   int limit, i;
   int    counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1); //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(i=0; i<limit; i++)   {
      S[i] = 0.0;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+