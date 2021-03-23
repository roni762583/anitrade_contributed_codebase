//+------------------------------------------------------------------+
//|                                           IL_i_SuperSmoother.mq4 |
//|                        Copyright 2013, Aharon Zbaida             |
//|                      https://sites.google.com/site/azhbaariodna/ |
//+------------------------------------------------------------------+
// As described by John Ehlers webinar: Effective Indicators for Trading Strategies (youtube)
// a1 = expvalue(-1.414 * 3.14159 / 10);
// b1 = 2 * a1 * Cosine(1.414 * 180 /10);
// c2 = b1;
// c3 = - a1 * a1;
// c1 = 1 - c2 - c3;
// Filt = c1 * (Close + Close[1]) / 2 + c2 * Filt[1] + c3 * Filt[2];
//
// Code conversion notes:
// 1) Filter is tuned to a 10 Bar cycle (attenuates shorter cycle periods)
// 2) Arguments of Trig. function are in degrees
// 3) [N] means value of the variable "N" Bars ago


#property copyright "Copyright 2013, Aharon Zbaida"
#property link      "https://sites.google.com/site/azhbaariodna/"

#property indicator_buffers 1
#property indicator_color1 Pink
#property indicator_chart_window

#define pi      3.1415926535897932384626433832795

extern double   criticalFreq = 10.0;                       //10 bar is presented

static double   a1, b1, c1, c3;                            //constant coefficients in formula
static double   filt0 = -9.0,                              //temp. vars. initialized as flag for initial value calc.
                filt1 = -9.0, 
                filt2 = -9.0;                              //temp. vars.
static datetime timeOfLastZeroBar = 0;                     //remebers last zero bar processed
       int      limit;
       
       int counted_bars;
//buffers
double filter[];

int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,filter);
   
   string s = "SuperSmoother()";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"SuperSmoother");
   return(0);
   
   filt0 = -9.0;
   counted_bars = 0;
}


int start()   {
   //initialize constants
   a1 = MathExp(0-MathSqrt(2.0) * pi / criticalFreq);                // ~= 0.641281 cf=10
   b1 = 2.0 * a1 * MathCos(MathSqrt(2.0) * pi / criticalFreq);       // ~= 1.21619
                                                           //c2 = b1, a constant! - put in b1 for c2
   c3 = - a1 * a1;                                         // ~= -0.41
   c1 = 1 - b1 - c3;                                       // ~= 0.19
   
   
   if(filt0 == -9.0)   {                                   // if first run, initialize with approximation
      filt2 = (Close[Bars] - Close[Bars-1]) / 2.0;
      filt1 = (Close[Bars-1] - Close[Bars-2]) / 2.0;
      filt0 = c1 * (Close[Bars-3] + Close[Bars-2]) / 2 + b1 * filt1 + c3 * filt2;
     
      for(int i = Bars-4; i>=0; i--)   {
         filt2 = filt1;                                    // filter[2] gets filter[1]
         filt1 = filt0;                                    // filter[1] gets filter[0]
         filt0 = c1 * (Close[i] + Close[i+1]) / 2 + b1 * filt1 + c3 * filt2; // put in b1 for c2
         filter[i] = filt0;
      }//for  

      timeOfLastZeroBar = Time[0];                         //note last bar calculated
   }//if
   
   if(Time[0]!=timeOfLastZeroBar)   {                      // if a new bar has formed, shift prev. values
      timeOfLastZeroBar = Time[0];                         // update latest zero bar timefilt2 = filt1;     
      filt2 = filt1;                                       // filter[2] gets filter[1]
      filt1 = filt0;                                       // filter[1] gets filter[0]               
   }//if
   
   filt0 = c1 * (Close[0] + Close[1]) / 2 + b1 * filt1 + c3 * filt2; // update zero bar continually
   filter[0] = filt0;
   
   return(0);
}//close function


int deinit()   {
   return(0);
}