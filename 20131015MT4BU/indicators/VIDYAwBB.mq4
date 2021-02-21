//+------------------------------------------------------------------+
//|                                                     VIDYAwBB.mq4 |
//|                            Copyright 2013, Yehuda Software Corp. |
//|                                            http://www.google.com |
//+------------------------------------------------------------------+
// VIDYA with it's Bolinger Bands - 13 la'Omer 5773

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue     //VIDYA
#property indicator_color2 Red      //UBB
#property indicator_color3 Yellow   //Mid-BB
#property indicator_color4 Green    //LBB


/*extern*/ int      m        = 1;                          //Kaufman’s Efficiency Ratio (ER) Period
extern int      N            = 3;                          //User selected constant smoothing period
extern int      BBperiod     = 10;                         //BB period
extern int      BBdeviations = 2;                          //deviations
extern int      BBshift      = 0;                          //BB shift
              
       double   VMA[],  //VIDYA
                UBB[],  //UBB
                MBB[],  //Mid-BB
                LBB[];  //LBB
                

static double   prevVMA        = 0.0;                      //to hold value of VMA from previous itteration

static double   a              = 0.0;                      //alpha
       double          y       = 0.0;                      //Kaufman’s Efficiency Ratio as Volatility Index
       double          d       = 0.0;                      //Direction
       double          v       = 0.0;                      //Volatility
       double          sum     = 0.0;                      //to hold sum in calculation of volatility
       double          result  = 0.0;                      //to store result during calculation
       
       double   ubb, mbb, lbb;


int init()  {
   IndicatorBuffers(4);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VMA);
   SetIndexLabel(0, "VMA");
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, UBB);
   SetIndexLabel(1, "UBB");
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, MBB);
   SetIndexLabel(2, "MBB");
   
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, LBB);
   SetIndexLabel(3, "LBB");

//   SetIndexEmptyValue(0, 0.0);

   string s = "VIDYAxBB("+N+","+BBperiod+","+BBdeviations+","+BBshift+")";
   IndicatorShortName(s);

   a = 2.0/(N+1);
   
   return(0);
}


int start()   {
   int counted_bars = IndicatorCounted();
   int i, limit;

   if(counted_bars == 0) {
      limit = Bars - m -1;                                    //to allow first value of 'd' below
      prevVMA = Close[limit];                              //initial value
   }
   
   if(counted_bars > 0)   {
      limit = Bars - counted_bars;
      prevVMA = VMA[limit+1];                              //set previous VMA value to that of bar perior to the one about to be calculated
   }

   for(i = limit; i >= 0; i--)   {
      d = MathAbs(Close[i]-Close[i+m]);
      sum = 0.0;
      
      for(int j = i+m; j>=i+1; j--)   {
         sum = sum + MathAbs(Close[j-1]-Close[j]);
      }
      
      //found rare ocassion of succesion of bars closing on same price yielding a zero sum, and therefore a divide by zero error
      if(sum==0.0) {
         sum = Point;
      }
      v = m*sum;
      y = d/v;
      
      //Print("a=",a,"  d=",d,"  v=",v,"  y=",y,"  Close[i]=",Close[i],"  prevVMA=", prevVMA);
      
      result  = a*y*Close[i] + (1-a*y)*prevVMA;
      //Print("result[",i,"]=", result, "     prevVMA=", prevVMA);
      prevVMA = result;
      VMA[i]  = result;
      if(i==limit)  {
         //Print("result = ", result, "    i=", i, "  j=", j, "  Bars =", Bars, "   Bar of: ", TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
         //Print("Close[limit]=", Close[limit]);
      }
   }//close for loop
   
   for(i = limit; i >= 0; i--)   {
      ubb = iBandsOnArray(VMA,0,BBperiod,BBdeviations,BBshift,MODE_UPPER,i);
      lbb = iBandsOnArray(VMA,0,BBperiod,BBdeviations,BBshift,MODE_LOWER,i);
      mbb = (ubb + lbb)/2.0;
      UBB[i] = ubb;
      MBB[i] = mbb;
      LBB[i] = lbb;
   }//close for loop
   
   return(0);
}


int deinit()   {

   return(0);
}

