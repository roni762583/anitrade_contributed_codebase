//+------------------------------------------------------------------+
//|                                                       FIR_MA.mq4 |
//|                                                  v.1  09/04/2006 |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 2
//Global constants
#define pi 3.141592653589793238462643383279502884197169399375105820974944592
//Input parameters
extern int  Periods = 4;   // 1/(2*Periods) sets the filter bandwidth
extern int  Taps    = 21;  // must be an odd number
extern int  Window  = 4;   // selects windowing function
//Indicator buffers
double FIRMA[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ArrayInitialize(FIRMA, EMPTY_VALUE);
   IndicatorBuffers(1);
   SetIndexBuffer(0, FIRMA);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   IndicatorShortName("FIRMA");
   SetIndexShift(0, -(Taps - 1) / 2);
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
int start()
  {
   double w[];
   ArrayResize(w, Taps);
   double wsum = 0.0;
   for(int k = 0; k < Taps; k++)
     {
       switch(Window)
         {
           // Rectangular window
           case 1: w[k] = 1.0; break; 
           // Hanning window
           case 2: w[k] = 0.50 - 0.50*MathCos(2.0*pi*k / Taps); break;
           // Hamming window
           case 3: w[k] = 0.54 - 0.46*MathCos(2.0*pi*k / Taps); break;
           //Blackman window
           case 4: w[k] = 0.42 - 0.50*MathCos(2.0*pi*k / Taps) + 
                          0.08*MathCos(4.0*pi*k / Taps); break;
           //Blackman-Harris window 
           case 5: w[k] = 0.35875 - 0.48829*MathCos(2.0*pi*k / Taps) + 
                          0.14128*MathCos(4.0*pi*k / Taps) - 
                          0.01168*MathCos(6.0*pi*k / Taps); break;
           //Rectangular window 
           default: w[k] = 1;break;
         }
       if(k != Taps / 2.0) 
           w[k] = w[k]*MathSin(pi*(k - Taps / 2.0) / Periods) / pi / (k - Taps / 2.0);
       wsum+=w[k];
     }
   int i = Bars - 1 - IndicatorCounted();
   while(i >= 0)
     {
       if(i <= Bars - Taps)
         {
           FIRMA[i] = 0.0;
           for(k = 0; k < Taps; k++) 
               FIRMA[i] += Close[i+k]*w[k] / wsum;
         }
       i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+