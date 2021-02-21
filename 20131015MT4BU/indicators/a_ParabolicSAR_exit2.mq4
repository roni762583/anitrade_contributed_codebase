//+------------------------------------------------------------------+
//|                                        a_ParabolicSAR_exit2.mq4   |
//|                                                           Aharon |
//|                                        http://www.anitani.com    |
//+-------------------------------------------------------------------
//prev.. ver has divide by zero error
#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.anitani.com/trading"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
// extern int AtrPeriod=14;
//---- buffers
double Buffer[];

static double cp;  //c prev. iteration
static bool   pState;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(1);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer);
   //SetIndexBuffer(1,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="a_ParabolicSAR_exit2";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
  {
   RefreshRates();
   int counted_bars = IndicatorCounted(),
       limit        = Bars-counted_bars;
   
   for(int i=0; i<limit; i++)   {
      double p = iCustom(NULL, 0, "Parabolic", 0, i);
      double b = 0.0;
      bool state;
      if(Close[i]>p) state = true;
      if(Close[i]<p) state = false;
      if(pState!=state) b = 1.0;
      pState = state;
      Buffer[i]= b;
   }
   
   return(0);
  }
//+------------------------------------------------------------------+