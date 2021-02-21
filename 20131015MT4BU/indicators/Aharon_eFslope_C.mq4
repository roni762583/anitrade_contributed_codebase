// Aharon_eFslope_C.mq4

//+------------------------------------------------------------------+
//|                                            Aharon_eFslope_HL.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

extern int    Period1 =   4;
extern int    Taps1   =   5;  //must be odd number
extern int    Window1   = 4;

double p0, p1, p2, p01, p02, p12, s01, s02, s12, t;
//double sh[], sl[];

double eFslope_H[];
double eFslope_L[];
double trigger[];

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      p0 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i);    //avgs represent prices
      p1 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i+1);
      p01 = (p0 - p1) * MathPow(10,Digits);
      eFslope_L[i] = p01/t;
   }
   
   for(i=0; i<limit; i++)  {
      p0 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i);    //avgs represent prices
      p1 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i+1);
      p01 = (p0 - p1) * MathPow(10,Digits);
      eFslope_H[i] = p01/t;
   }
   
   for(i=0; i<limit; i++)  {  ///may need to use high or open or close 
      int j = MathCeil((Taps1-1)/2);
      if(eFslope_L[i]<0) trigger[i-j] = -1.0; //short 
         else if(eFslope_L[i]>0) trigger[i-j] = 1.0; //long 
            else trigger[i] = 0.0;
   }
              
   return(0);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
//   ArrayResize(sl, Bars);
   SetLevelValue(0,0.0);
   
   IndicatorBuffers(3);

   string short_name;
   short_name = "eFslope_HL(" + Period1 + ", " + Taps1 + ", " + Window1 + ") in pips/min.";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "eFslope_H");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, eFslope_H);
   
   SetIndexLabel(1, "eFslope_L");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,eFslope_L);
   
   SetIndexLabel(2, "trigger");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,trigger);
   
   t = Period();              //delta time per bar in minutes, this is approximate since dont know the time high or low are reached
   
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}