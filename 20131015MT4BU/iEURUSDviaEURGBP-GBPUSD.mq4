//+------------------------------------------------------------------+
//|                                      iEURUSDviaEURGBP-GBPUSD.mq4 |
//|                            Copyright 2012, Yehuda Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Yehuda Software Corp."
#property link      ""

#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 White


extern string pair1  = "EURGBPm";
extern string pair2  = "GBPUSDm"; //SELL BOTH
extern bool   invert = false;

double EURUSD[];

int init()  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,EURUSD);
   SetIndexLabel(0,"EURUSD Index");
   string s = "EURUSD()";
   IndicatorShortName(s);

   return(0);
}



int start()  {
   int    i, k, counted_bars = IndicatorCounted();
   //---- last counted bar will be recounted
   int limit = Bars - counted_bars;
   if(counted_bars > 0)  limit++;
   
   for(i = limit; i >= 0; i--)  {
      //index i-is latest (2), while (i+1)-is previous (1) index
      double C2 = iClose(pair2, 0, i);
      double C1 = iClose(pair1, 0, i);
      
      
      
      EURUSD[i] = C1*C2;

   }   //close for loop 
   
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

