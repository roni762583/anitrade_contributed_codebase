//+------------------------------------------------------------------+
//|                                               Aharon_Bal_Sum.mq4 |
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
// want to reset this sum to zero if median price crosses 10-period MA of the median price 

   if(iMA(NULL,0,1,0,0,4,i+2)>iMA(NULL,0,ExtParam1,0,0,4,i+2) && iMA(NULL,0,1,0,0,4,i)<iMA(NULL,0,ExtParam1,0,0,4,i)) ExtMapBuffer1[i+1]=0;
   if(iMA(NULL,0,1,0,0,4,i+2)<iMA(NULL,0,ExtParam1,0,0,4,i+2) && iMA(NULL,0,1,0,0,4,i)>iMA(NULL,0,ExtParam1,0,0,4,i)) ExtMapBuffer1[i+1]=0;
   
   ExtMapBuffer1[i]=ExtMapBuffer1[i+1]+(((High[i]-Low[i])/2)+Low[i])-((MathAbs(Close[i]-Open[i])/2)+MathMin(Open[i],Close[i]));

   
   
   i--;
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+