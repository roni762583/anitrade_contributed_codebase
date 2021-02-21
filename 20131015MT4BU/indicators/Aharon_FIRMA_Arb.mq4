//+------------------------------------------------------------------+
//|                                             Aharon_FIRMA_Arb.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// This is intended to produce a function that will return a FIRMA_FULL Time Series from an Arbitarary input series
// parameters will include existing settings, in addition to choosing prices(O,H,L,C, etc.) and Time Frame

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
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Gold
#property indicator_color3 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
//Global constants
#define pi 3.141592653589793238462643383279502884197169399375105820974944592
//Input parameters
extern int  Periods = 20;   // 1/(2*Periods) sets the filter bandwidth
extern int  Taps    = 21;  // must be an odd number
extern int  Window  = 4;   // selects windowing function
//Global variables
double w[], wsum, sx2, sx3, sx4, sx5, sx6, den; 
double ArbArray[];                                         //Arbitrary data array to feed ArbFIRMA() function

int n;
//Indicator buffers
double FIRMA[];
double ARMA[];
double Full[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   
                                                           //Initialize indicator
   IndicatorBuffers(3);
   SetIndexBuffer(0, FIRMA);
   SetIndexBuffer(1, ARMA);
   SetIndexBuffer(2, Full);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   IndicatorShortName("FIRMA_Arb");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()   {
   f = false;
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()   { 
   ArbFIRMA(ArbArray, w, Taps);
}

double ArbFIRMA(double InArray[], w, Taps)  {
   ////////////////////////
   //Calculate weights
   ArrayResize(w, Taps);
   wsum = 0.0;
   for(int k = 0; k < Taps; k++)
     {
       switch(Window)  {                                           //this part sets the weights IAW windowing function
         
           case 1:  w[k] = 1.0; // Rectangular window
                    break;
           case 2:  w[k] = 0.50 - 0.50*MathCos(2.0*pi*k / Taps);   // Hanning window
                    break;
           case 3:  w[k] = 0.54 - 0.46*MathCos(2.0*pi*k / Taps);   // Hamming window
                    break;
           case 4:  w[k] = 0.42 - 0.50*MathCos(2.0*pi*k / Taps) +  
                           0.08*MathCos(4.0*pi*k / Taps);          // Blackman window
                    break;
           case 5:  w[k] = 0.35875 - 0.48829*MathCos(2.0*pi*k / Taps) + 
                           0.14128*MathCos(4.0*pi*k / Taps) - 
                           0.01168*MathCos(6.0*pi*k / Taps);       // Blackman - Harris window
                    break; 
           default: w[k] = 1;                                      //Rectangular window 
                    break;
       }
       
       if(k != Taps / 2.0) 
           w[k] = w[k]*MathSin(pi*(k - Taps / 2.0) / Periods) / pi / (k - Taps / 2.0);
       wsum += w[k];
   }
                                                           //Calculate sums for the least-squares method
   n = (Taps - 1) / 2;
   sx2 = (2*n + 1) / 3.0;
   sx3 = n*(n + 1) / 2.0;
   sx4 = sx2*(3*n*n+3*n - 1) / 5.0;
   sx5 = sx3*(2*n*n+2*n - 1) / 3.0;
   sx6 = sx2*(3*n*n*n*(n + 2) - 3*n+1) / 7.0;
   den = sx6*sx4 / sx5 - sx5;
   
   ////////////////////////
   int j,n2;

                                                           //Calculate FIR MA for all bars except for the last n bars

   ArrayInitialize(FIRMA, EMPTY_VALUE);
   
   
    int start,start_j;
    
    start_j=ObjectGet("start",OBJPROP_TIME1);     
  
    if(GetLastError()==0) start=iBarShift(NULL,0,start_j,False); else start=0;
    
    n2=n+start;
    
    for(int i = start; i <= Bars - Taps; i++)    {
       FIRMA[i+n] = 0.0;
       for(int k = 0; k < Taps; k++)
           FIRMA[i+n] += Close[i+k]*w[k] / wsum;
    }
                                                           //Calculate regressive MA for the remaining n bars
    double a0 = FIRMA[n2];
    double a1 = FIRMA[n2] - FIRMA[n2+1];
    double sx2y = 0.0;
    double sx3y = 0.0;
   
    for(i = 0; i <= n; i++)    {
       sx2y += i*i*Close[n2-i];
       sx3y += i*i*i*Close[n2-i];
    }
    
    sx2y = 2.0*sx2y / n / (n + 1);
    sx3y = 2.0*sx3y / n / (n + 1);
    
    double p = sx2y - a0*sx2 - a1*sx3;
    double q = sx3y - a0*sx3 - a1*sx4;
    double a2 = (p*sx6 / sx5 - q) / den;
    double a3 = (q*sx4 / sx5 - p) / den;
    
    ArrayInitialize(ARMA, EMPTY_VALUE);
    for(i = 0; i <= n; i++)
       ARMA[n2-i] = a0 + i*a1 + i*i*a2 + i*i*i*a3;
       
    for(i=0; i<= Bars; i++)   {
      if(FIRMA[i] != 0 && FIRMA[i] != NULL) Full[i]=FIRMA[i];  ///else if give either ARMA or FIRMA but not both!!
      //  else if(ARMA[i]!= 0 || ARMA[i] != NULL) Full[i]=ARMA[i];   //if(FIRMA[i] == 0 || FIRMA[i] == NULL) Full[i]=ARMA[i];
      //if(ARMA[i]!= 0 && ARMA[i] != NULL) Full[i]=ARMA[i];
    }
   
    for(i=0; i<= n; i++)   {
       Full[i]=ARMA[i];
    }
   
    return(0);
}
//+------------------------------------------------------------------+


