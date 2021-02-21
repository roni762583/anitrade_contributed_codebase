//+------------------------------------------------------------------+
//|                                  iTrndHLBOPmod.mq4                  |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//  to indicate dist past HLBOP's if a price penetrated the LBOP or HBOP per Reaction Trend System by J.W. Wilder pg. 71-72
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White
//#property indicator_color2 Green
//#property indicator_color3 Red
//#property indicator_color4 Blue

#property indicator_separate_window


double sig[];//, S1[], HBOP[], LBOP[];


int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sig);
   SetIndexLabel(0,"H_L_Break_outs");
   /*
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,S1);
   SetIndexLabel(0,"S1");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,HBOP);
   SetIndexLabel(0,"HBOP");
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LBOP);
   SetIndexLabel(0,"LBOP");
   */
   string s = "HLBOP()";
   IndicatorShortName(s);
   
   return(0);
}



int start()  {
   int    i, k, counted_bars = IndicatorCounted();
   //---- last counted bar will be recounted
   int limit = Bars - counted_bars;
   if(counted_bars > 0) 
       limit++;

   for(i = limit; i >= 0; i--)  {
      //B1[i-1]   = 2*(High[i]+Low[i]+Close[i])/3 - High[i];
      //S1[i-1]   = 2*(High[i]+Low[i]+Close[i])/3 - Low[i];
      double s1 = 0.0;
      double xBar = (High[i+1]+Low[i+1]+Close[i+1])/3;
      double hbop = 2*xBar - 2*Low[i+1] + High[i+1];
      double lbop = 2*xBar - 2*High[i+1] + Low[i+1];
      
      
      if(Low[i] < lbop) s1 = Low[i] - lbop;
      if(High[i] > hbop) s1 = High[i] - hbop;
         
      sig[i] = s1;

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

