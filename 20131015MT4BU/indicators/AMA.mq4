//+------------------------------------------------------------------+
//|                                                        AMA.mq4 |
//|                            Copyright 2013, Yehuda Software Corp. |
//|                                            http://www.google.com |
//+------------------------------------------------------------------+
// VIDYA is Volatility Index DYnamic Average - it adjusts averagind period dynamically based on volatility to be more reactive during high-volatility
// a.k.a. Variable Moving Average     VMA = a*y*Price + (1-a*y)*VMA_previous
// a = 2/(N+1)                                                  this is called alpha
// N = User selected constant smoothing period
// y = d/v                                                      this is called Volatility Index, or Kaufman’s Efficiency Ratio (ER)
// d = MathAbs(Close[i]-Close[i-m])                             this is called Direction
// m                               is  a          user defined constant called Efficiency Ratio Period 
// v = m*(Sum(MathAbs(Close[j]-Close[j-1]), from j=i to j=i-m)  this is called Volatility
// Alternatively Volatility Index can be MathAbs(Chande Momentum Oscilator)/100
// Fri. 04/05/2013 Asara Yamim LaOmer
// Wed. PM 16 la'Omer 5773
//AMA try according to one article
// AMA = C*(Close[0]-AMA[1])+AMA[1]
// C = ssc^2
// ssc = ER * (2/(2+1) - 2/(30+1)) + 2/(30+1);  kauffman suggested period from 2 (fast) to 30 (slow)
// ER = ABS(Direction / Volatility)
// Direction = Close[0] - Close[1]
// Volatility = Sum( ABS(Close[0] - Close[1]), n-times) kauffman suggested n=10

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue

extern int      n              = 10;                        //Kaufman suggested 10
extern int      nmin           = 2;                         //minimum period (during sideways market)
extern int      nmax           = 30;                        //maximum period (during trending market)
              
       double   AMA[];

static double   prevAMA        = 0.0;                      //to hold value of AMA from previous itteration

static double   Volatility     = 0.0;                      //
       double   Direction      = 0.0;                      //
       double   ER             = 0.0;                      //
       double   SSC            = 0.0;                      //
       double   C              = 0.0;                      //
       double   result         = 0.0;                      //to store result during calculation


int init()  {
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, AMA);
   SetIndexLabel(0, "AMA");
   SetIndexEmptyValue(0, 0.0);
   string s = "AMA(" + n + ")";
   IndicatorShortName(s);
   return(0);
}


int start()   {
   int counted_bars = IndicatorCounted();
   int i, limit;

   if(counted_bars == 0) {
      limit = Bars - n - 1;                                //to allow first value
      prevAMA = Close[limit];                              //initial value
   }
   
   if(counted_bars > 0)   {
      limit = Bars - counted_bars;
      prevAMA = AMA[limit+1];                              //set previous VMA value to that of bar perior to the one about to be calculated
   }

   for(i = limit; i >= 0; i--)   {

      Direction = Close[i]-Close[i+1];
      //calc volatility
      Volatility = 0.0;
      for(int j = i; j<=i+n-1; j++)   {
         Volatility = Volatility + MathAbs(Close[j]-Close[j+1]);
      }
      //Volatility = Volatility/n; //not in original
      ER = MathAbs(Direction / Volatility);
      //found rare ocassion of succesion of bars closing on same price yielding a zero sum, and therefore a divide by zero error
      if(Volatility==0.0) Volatility = Point;
      SSC = ER*((2.0/(nmin+1.0))-(2.0/(nmax+1.0))) + (2.0/(nmax+1.0));
      C = MathPow(SSC, 2);
      
      result  = C*(Close[i] - prevAMA) + prevAMA;
      
      prevAMA = result;
      AMA[i]  = result;
      
   }//close for loop 
   
   return(0);
}


int deinit()   {

   return(0);
}

