//+------------------------------------------------------------------+
//|                                  iWilderRxnTrndBounds.mq4        |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
// indicator to display boundaries of Reaction Trend System by J.W. Wilder pg. 71-72
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Blue

#property indicator_chart_window


double B1[], S1[], HBOP[], LBOP[];


int init()  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,B1);
   SetIndexLabel(0,"B1");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,S1);
   SetIndexLabel(0,"S1");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,HBOP);
   SetIndexLabel(0,"HBOP");
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LBOP);
   SetIndexLabel(0,"LBOP");
   
   string s = "iWilderRxnTrndBounds()";
   IndicatorShortName(s);
   IndicatorDigits(Digits);
   
   return(0);
}



int start()  {
   int    i, k, counted_bars = IndicatorCounted();
   //---- last counted bar will be recounted
   int limit = Bars - counted_bars;
   if(counted_bars > 0) 
       limit++;

   for(i = limit; i >= 0; i--)  {
      B1[i-1]   = 2*(High[i]+Low[i]+Close[i])/3 - High[i];
      S1[i-1]   = 2*(High[i]+Low[i]+Close[i])/3 - Low[i];
      HBOP[i-1] = 2*(High[i]+Low[i]+Close[i])/3 - 2*Low[i] +High[i];
      LBOP[i-1] = 2*(High[i]+Low[i]+Close[i])/3 - 2*High[i] +Low[i];
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

