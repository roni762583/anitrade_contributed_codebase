//+------------------------------------------------------------------+
//|                                                      VIDYA-H.mq4 |
//|                            Copyright 2013, Yehuda Software Corp. |
//|                                            http://www.google.com |
//+------------------------------------------------------------------+
// VIDYA is Volatility Index DYnamic Average - it adjusts averagind period dynamically based on volatility to be more reactive during high-volatility
// a.k.a. Variable Moving Average     VMA = a*y*Price + (1-a*y)*VMA_previous
// a = 2/(N+1)                                                  this is called alpha
// N = User selected constant smoothing period
// y = d/v                                                      this is called Volatility Index, or Kaufman’s Efficiency Ratio (ER)
// d = MathAbs(High[i]-High[i-m])                             this is called Direction
// m                               is  a          user defined constant called Efficiency Ratio Period 
// v = m*(Sum(MathAbs(High[j]-High[j-1]), from j=i to j=i-m)  this is called Volatility
// Alternatively Volatility Index can be MathAbs(Chande Momentum Oscilator)/100
// Fri. 04/05/2013 Asara Yamim LaOmer

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red


extern int      m              = 1;                         //Kaufman’s Efficiency Ratio (ER) Period
extern int      N              = 3;                         //User selected constant smoothing period
              
              
       double   dSomeOtherArray[], VMA[];

static double   prevVMA        = 0.0;                      //to hold value of VMA from previous itteration

static double   a              = 0.0;                      //alpha
       double          y       = 0.0;                      //Kaufman’s Efficiency Ratio as Volatility Index
       double          d       = 0.0;                      //Direction
       double          v       = 0.0;                      //Volatility
       double          sum     = 0.0;                      //to hold sum in calculation of volatility
       double          result  = 0.0;                      //to store result during calculation


int init()  {
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VMA);
   SetIndexLabel(0, "VMA");

   SetIndexEmptyValue(0, 0.0);

   string s = "VMA(" + m + ", " + N + ")";
   IndicatorShortName(s);

   a = 2.0/(N+1);
   
   return(0);
}


int start()   {
   int counted_bars = IndicatorCounted();
   int i, limit;

   if(counted_bars == 0) {
      limit = Bars - m -1;                                    //to allow first value of 'd' below
      prevVMA = High[limit];                              //initial value
   }
   
   if(counted_bars > 0)   {
      limit = Bars - counted_bars;
      prevVMA = VMA[limit+1];                              //set previous VMA value to that of bar perior to the one about to be calculated
   }

   for(i = limit; i >= 0; i--)   {
      d = MathAbs(High[i]-High[i+m]);
      sum = 0.0;
      
      for(int j = i+m; j>=i+1; j--)   {
         sum = sum + MathAbs(High[j-1]-High[j]);
      }
      
      //found rare ocassion of succesion of bars closing on same price yielding a zero sum, and therefore a divide by zero error
      if(sum==0.0) {
         sum = Point;
      }
      v = m*sum;
      y = d/v;
      
      //Print("a=",a,"  d=",d,"  v=",v,"  y=",y,"  High[i]=",High[i],"  prevVMA=", prevVMA);
      
      result  = a*y*High[i] + (1-a*y)*prevVMA;
      //Print("result[",i,"]=", result, "     prevVMA=", prevVMA);
      prevVMA = result;
      VMA[i]  = result;
      if(i==limit)  {
         //Print("result = ", result, "    i=", i, "  j=", j, "  Bars =", Bars, "   Bar of: ", TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
         //Print("High[limit]=", High[limit]);
      }
      
   }//close for loop 
   
   return(0);
}


int deinit()   {

   return(0);
}

