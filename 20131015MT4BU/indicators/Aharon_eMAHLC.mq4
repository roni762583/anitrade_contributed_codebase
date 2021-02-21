//+------------------------------------------------------------------+
//Aharon_eMAHLC.mq4
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

extern int    MAlen =   7;

double maH, maL;
// buffers
double s0[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
   SetLevelValue(0,0.0);
   
   IndicatorBuffers(1);
      
   string short_name;
   short_name = "Aharon_eMAHLC(" + MAlen + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "signal");
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, s0);  
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
   int limit, i, shftI;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      maH = iMA(NULL, 0, MAlen, 0, MODE_SMA, PRICE_HIGH, i);
      maL = iMA(NULL, 0, MAlen, 0, MODE_SMA, PRICE_LOW, i);
      //maHLo2 = iMA(NULL, 0, MAlen, 0, MODE_SMA, PRICE_MEDIAN, i);
      s0[i] = 0.0;
      if(Close[i+1]>maH) s0[i] = 1.0;
      else if(Close[i+1]<maL) s0[i] = -1.0;
   }
   
   return(0);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}