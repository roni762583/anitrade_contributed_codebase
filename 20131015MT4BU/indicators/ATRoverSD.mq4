//ATRoverSD
#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int ATRperiod   = 1;

extern int SDperiod    = 20;//default based on close price and simple averaging


double Sig[];

static double sig;

double result = 0.0;

int init()  {
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Sig);
   SetIndexLabel(0, "ATR/SD");
   
   string s = "ATR over SD("+ATRperiod+", "+SDperiod+")";
   IndicatorShortName(s);
   return(0);
}


int start()   {
  
   
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars==0) limit=Bars-50; //if first run, give room to prime the ma calc.
   limit=Bars-counted_bars;


   for(i = limit; i>=0; i--)   {
      Sig[i] = iATR(Symbol(),0,ATRperiod,i)/MathMax(iStdDev(Symbol(),0,SDperiod,0,MODE_SMA,PRICE_CLOSE,i), Point/1000.0);
   }//close for()
   
   return(0);
}//
//
      //
      //

int deinit()   {

   return(0);
}

