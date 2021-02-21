//+------------------------------------------------------------------+
//|                                             Aharon_eFs_L.mq4.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red

extern int    Period1 =   4;
extern int    Taps    =   5;  //must be odd number
extern int    Window  =   4;
extern int    LTF     =   60;
extern int    TP      =   10;

double signal0, signal1, signalLTF, p;

double s1[], pips0[], pips1[], pipsLTF[], tm0[], tm1[], tmLTF[];


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
   
      // Trading criteria
      signal0   = iCustom(NULL, 0, "Aharon_eFslope_HL",  Period1, Taps, Window, 1, i);
      signal1   = iCustom(NULL, 0, "Aharon_eFslope_HL",  Period1, Taps, Window, 1, i+1);
      signalLTF = iCustom(NULL, LTF, "Aharon_eFslope_HL",  Period1, Taps, Window, 1, i);
      
      s1[i] = 0.0;
      //---- sell conditions
      if(signal0<0 && signal1>0 && signalLTF < 0)   { //if the current TF slope switched in the direction of the LTF slope (down)
         s1[i] = -1.0;
         pips0[i] = signal0*p;
         pips1[i] = signal1*p;
         pipsLTF[i] = signalLTF*p;
         tm0[i]   = 1/signal0 * TP;
         tm1[i]   = 1/signal1 * TP;
         tmLTF[i]   = 1/signalLTF * TP;
      }
   
      //---- buy conditions
      if(signal0>0 && signal1<0 && signalLTF>0)   { //if the current TF slope switched in the direction of the LTF slope (up)
         s1[i] = 1.0;
         pips0[i] = signal0*p;
         pips1[i] = signal1*p;
         pipsLTF[i] = signalLTF*p;
         tm0[i]   = 1/signal0 * TP;
         tm1[i]   = 1/signal1 * TP;
         tmLTF[i]   = 1/signalLTF * TP;
      }
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
   
   IndicatorBuffers(7);

   string short_name;
   short_name = "eFs_L(" + Period1 + ", " + Taps + ", " + Window + ", " + TP + ", " + LTF + ") see tab for print statement";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "s1");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, s1);
   
   SetIndexLabel(1, "pips0");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, pips0);
   
   SetIndexLabel(2, "pips1");
   SetIndexStyle(2,  DRAW_LINE);
   SetIndexBuffer(2, pips1);
   
   SetIndexLabel(3, "pipsLTF");
   SetIndexStyle(3,  DRAW_LINE);
   SetIndexBuffer(3, pipsLTF);
   
   SetIndexLabel(4, "tm0");
   SetIndexStyle(4,  DRAW_LINE);
   SetIndexBuffer(4, tm0);
   
   SetIndexLabel(5, "tm1");
   SetIndexStyle(5,  DRAW_LINE);
   SetIndexBuffer(5, tm1);
   
   SetIndexLabel(6, "tmLTF");
   SetIndexStyle(6,  DRAW_LINE);
   SetIndexBuffer(6, tmLTF);
   
   p = Period();
   
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}