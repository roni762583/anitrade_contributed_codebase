//+------------------------------------------------------------------+
//|                                        Aharon_Bands_on_ATR20.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
//---- buffers
double D[];
double BBu[];
double BBl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
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
   for(i=0; i<limit; i++)  {
      D[i]=iATR(NULL, 0, 20, i);
   }
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, 20, 2, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, 20, 2, 0, 2,i);
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+