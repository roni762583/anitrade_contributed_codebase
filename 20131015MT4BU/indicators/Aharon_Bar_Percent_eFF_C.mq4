//                 Aharon_eFF_C.mq4
//+------------------------------------------------------------------+
//|                                            Aharon_FIRMA_Full.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                            Aharon_FIRMA_ARMA.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

// http://codebase.mql4.com/source/8133
//+------------------------------------------------------------------+
//|                                                       AFIRMA.mq4 |
//|                                          Copyright © 2006, gpwr. |
//+------------------------------------------------------------------+
 
 
#property copyright "Copyright © 2006, gpwr."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Gold
#property indicator_color3 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
//Global constants

//Input parameters
extern int  Periods = 4;   // 1/(2*Periods) sets the filter bandwidth
extern int  Taps    = 21;  // must be an odd number
extern int  Window  = 4;   // selects windowing function
//Global variables


//Indicator buffers
double A[];
double B[];
double C[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   //Initialize indicator
   IndicatorBuffers(3);
   SetIndexBuffer(0, A);
   SetIndexBuffer(1, B);
   SetIndexBuffer(2, C);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   IndicatorShortName("Aharon_Bar_Perent_eFF_C");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
    return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()  { 
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   ArrayInitialize(A, EMPTY_VALUE);
   ArrayInitialize(B, EMPTY_VALUE);
   ArrayInitialize(C, EMPTY_VALUE);
   
// Set values
   for(i=0; i<limit; i++)  {

   
     
   }
   
   
   return(0);
  }
//+------------------------------------------------------------------+


