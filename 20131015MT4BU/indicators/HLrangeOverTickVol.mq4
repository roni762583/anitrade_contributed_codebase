//HLrangeOverTickVol.mq4
#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

double Sig[];

static double sig;

double result = 0.0;

int init()  {
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, Sig);
   SetIndexLabel(0, "HLrangeOverTickVol");
   
   string s = "HLrangeOverTickVol";
   IndicatorShortName(s);
   return(0);
}


int start()   {
  
   
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars==0) limit=Bars-50; //if first run, give room to prime the ma calc.
   limit=Bars-counted_bars;
   double v;
   for(i = limit; i>=0; i--)   {
      v = MathMax(Volume[i],1.0);
      Sig[i] = (High[i]-Low[i])/(v*Point);
   }//close for()
   
   return(0);
}//
//
      //
      //

int deinit()   {

   return(0);
}

