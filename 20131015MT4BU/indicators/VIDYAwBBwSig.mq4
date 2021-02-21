//+------------------------------------------------------------------+
//|                                                 VIDYAwBBwSig.mq4 |
//|                            Copyright 2013, Yehuda Software Corp. |
//|                                            http://www.google.com |
//+------------------------------------------------------------------+
// VIDYA with it's Bolinger Bands - 13 la'Omer 5773

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_separate_window
#property indicator_buffers 2
/*
#property indicator_color1 Blue     //VIDYA
#property indicator_color2 Green    //UBB
#property indicator_color3 Yellow   //Mid-BB
#property indicator_color4 Green    //LBB
*/
#property indicator_color1 Red      //EntrySig
#property indicator_color2 White    //ExitSig



/*extern*/ int      m        = 1;                          //Kaufman’s Efficiency Ratio (ER) Period
extern int      N            = 3;                          //User selected constant smoothing period
extern int      BBperiod     = 10;                         //BB period
extern int      BBdeviations = 2;                          //deviations
extern int      BBshift      = 0;                          //BB shift
              
       double   VMA[],  //VIDYA
                UBB[],  //UBB
                MBB[],  //Mid-BB
                LBB[],  //LBB
                EnSig[],//Entry Signal +1 is long, -1 is short 
                ExSig[];//Exit Signal 1 is Exit, zero is off
                

static double   prevVMA        = 0.0;                      //to hold value of VMA from previous itteration

static double   a              = 0.0;                      //alpha
       double          y       = 0.0;                      //Kaufman’s Efficiency Ratio as Volatility Index
       double          d       = 0.0;                      //Direction
       double          v       = 0.0;                      //Volatility
       double          sum     = 0.0;                      //to hold sum in calculation of volatility
       double          result  = 0.0;                      //to store result during calculation
       
       double   ubb, mbb, lbb, ensig, exsig;


int init()  {
   IndicatorBuffers(6);
   
   //SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(4, VMA);
   //SetIndexLabel(0, "VMA");
   
   //SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(5, UBB);
   //SetIndexLabel(1, "UBB");
   
   //SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, MBB);
   //SetIndexLabel(2, "MBB");
   
   //SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, LBB);
   //SetIndexLabel(3, "LBB");
   
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, EnSig);
   SetIndexLabel(0, "EnSig");

   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, ExSig);
   SetIndexLabel(1, "ExSig");

   string s = "VIDYAwBBwSig("+N+","+BBperiod+","+BBdeviations+","+BBshift+")";
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
      /*
      if(VMA[i]>lbb && VMA[i]<ubb)   {
         ensig = mbb;
      }
      */
      
      ensig = 0.0; //precondition entry signal to be off unless it is triggered below 
      exsig = 0.0; //precondition exit signal to be off unless it is triggered below 
      
      if((VMA[i+1]>mbb && VMA[i]<mbb) || (VMA[i+1]<mbb && VMA[i]>mbb))   { //if VMA crossed mid-BB --> ext sig. on!   
         exsig =  1.0;
      }
      
      if(VMA[i]<lbb)   {                                                   //if VMA < lbb         --> Sig=lbb
         ensig = -1.0;
         //Print("VMA[",i,"]=",VMA[i],",    ensig=",ensig);
      }
      
      if(VMA[i]>ubb)   {                                                   //if VMA > ubb        --> Sig=ubb
         ensig =  1.0;
         //Print("VMA[",i,"]=",VMA[i],",    ensig=",ensig);
      }
      
      EnSig[i] = ensig;
      ExSig[i] = exsig;
      
   }//close for loop
   
   return(0);
}


int deinit()   {

   return(0);
}

