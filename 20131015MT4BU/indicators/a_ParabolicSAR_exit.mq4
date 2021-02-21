//+------------------------------------------------------------------+
//|                                        a_ParabolicSAR_exit.mq4   |
//|                                                           Aharon |
//|                                        http://www.anitani.com    |
//+-------------------------------------------------------------------

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
   short_name="a_ParabolicSAR_exit";
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
      double c = Close[i] / iCustom(NULL, 0, "Parabolic", 0, i);
      if(
           (cp>1.0 && c<1.0) ||
           (cp<1.0 && c>1.0)
        ) Buffer[i]= 1.0;
        
      else Buffer[i]= 0.0;
      cp = c;
   }
   
   return(0);
  }
//+------------------------------------------------------------------+