//+------------------------------------------------------------------+
//|                                       Aharon_Slope_Typ_Price.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
extern int       ExtParam1=10;
extern int       ExtParam2;
extern int       ExtParam3;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
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
   int    i, counted_bars=IndicatorCounted();
      
//----
   i=Bars-counted_bars-1;
   while(i>=0) {
   // slope=arctan [(typ. price i  - typ. price i+1)                            / (# of minutes)] * factor for degrees
   ExtMapBuffer1[i]= MathArctan( (((High[i]+Low[i])/2)-((High[i+2]+Low[i+2])/2)) / (Period()) )    * (180/3.1415926535897);

   
   
   i--;
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+