//                 Aharon_eFF_C_inversion.mq4
//+------------------------------------------------------------------+
//|                           Aharon                                 |

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 1

//Input parameters
extern int  Periods = 20;   // 1/(2*Periods) sets the filter bandwidth
extern int  Taps    = 21;  // must be an odd number
extern int  Window  = 4;   // selects windowing function

//Indicator buffers
double A[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   //Initialize indicator
   IndicatorBuffers(1);
   SetIndexBuffer(0, A);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   
   IndicatorShortName("Aharon_eFF_C_inversion");
   
   ArrayInitialize(A, EMPTY_VALUE);
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

   // Set values
   for(i=0; i<limit; i++)  {
     double f0, f1, f2;
     f0 = iCustom(Symbol(), Period(), "Aharon_eFF_C",  Periods, Taps, Window,  2, i);
     f1 = iCustom(Symbol(), Period(), "Aharon_eFF_C",  Periods, Taps, Window,  2, i+1);
     f2 = iCustom(Symbol(), Period(), "Aharon_eFF_C",  Periods, Taps, Window,  2, i+2);
     //max
     if(f2<f1 && f1>f0) A[i+1]=1.0;
     //min 
     if(f2>f1 && f1<f0) A[i+1]=-1.0;
   }
   
   return(0);
  }
//+------------------------------------------------------------------+


