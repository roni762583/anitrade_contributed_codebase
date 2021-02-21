//+------------------------------------------------------------------+
//|                                             Aharon_eFs_L2.mq4.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

extern int    Period1 =   4;
extern int    Taps    =   5;  //must be odd number
extern int    Window  =   4;

extern int    OTF     =   1;  //lower timeframe

// buffers
double s0[], s1[], s3[];

int p;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
   SetLevelValue(0,0.0);
   
   IndicatorBuffers(3);
   
   p = Period();
   
   string short_name;
   short_name = "eFs_C2(" + Period1 + ", " + Taps + ", " + Window + ", " + OTF + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, StringConcatenate("Slp.Chrt ", p, " TF (B)"));
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, s0);
   
   SetIndexLabel(1, StringConcatenate("Slp. OTF ", OTF, " TF (R)"));
   SetIndexStyle(1,  DRAW_HISTOGRAM);
   SetIndexBuffer(1, s1);
   
   SetIndexLabel(2, "Newly Agree (G)");
   SetIndexStyle(2,  DRAW_LINE);
   SetIndexBuffer(2, s3);
   
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
         
      // in OTF, what is shift of bar that opens at the open time of bar i in HTF...
      s0[i] = iCustom(NULL, p, "Aharon_eFslope_C",  Period1, Taps, Window, 1, i); //chart timeframe slope
      shftI = iBarShift(NULL, OTF, iTime(NULL, p, i), false);                      //shift in OTF of bar with open time corresponding to open of chart bar
      s1[i] = iCustom(NULL, OTF, "Aharon_eFslope_C",  Period1, Taps, Window, 1, shftI);  //
   }              
   
   for(i=0; i<limit; i++)  {
      s3[i] = 0.0;
      if(s0[i]>0 && s1[i]>0 && s0[i+1]<0 && s1[i+1]<0) s3[i] = 1.0;  // agree up
      if(s0[i]<0 && s1[i]<0 && s0[i+1]>0 && s1[i+1]>0) s3[i] = -1.0;  // agree down
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