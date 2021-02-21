//+------------------------------------------------------------------+
//|                                                       aTrend.mq4 |
#property  copyright "Copyright © 2004, Anitani Software Corp."
#property  link      "http://www.anitani.com"
//---- indicator settings
#property  indicator_separate_window

#property  indicator_buffers 4
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property  indicator_color3  Yellow
#property  indicator_color4  White

//---- indicator parameters
static double s1, s2, p1;

//---- indicator buffers
double     aTrendBuffer[];
double     confirmation[], agreement[], persistanceSum[];


int init()  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_LINE);
   
   IndicatorDigits(Digits+1);
   
//---- indicator buffers mapping
   SetIndexBuffer(0,aTrendBuffer);
   SetIndexBuffer(1,confirmation);
   SetIndexBuffer(2,agreement);
   SetIndexBuffer(3,persistanceSum);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("aTrend()");

   SetIndexLabel(0,"aTrend");
   SetIndexLabel(1,"confirmation");
   SetIndexLabel(2,"agreement");
   SetIndexLabel(3,"persistanceSum");

//---- initialization done
   return(0);
}


int start()  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   

   for(int i=limit; i>=0; i--)  {
      if( s1 == s2 ) {                   // if were agreement last bar, set p1 to direction value
         p1 = s1;
      }
      s1 = 0.0;
      s2 = 0.0;
      
      if(High[i]< High[i+1]) s1 = -1.0 ; //decreasing highs
      if(Low[i] > Low[i+1] ) s1 =  1.0 ; //increasing lows
      aTrendBuffer[i] = s1;
      
      if(Low[i]<Low[i+1]  )  s2 = -1.0 ; //decreasing lows
      if(High[i]>High[i+1])  s2 =  1.0 ; //increasing highs
      confirmation[i] = s2;
      
      if( s1 == s2 && s1 != 0.0) {                   // if both agree, and signal present this bar ...
         agreement[i] = 1.0;             // indicate so, and 
         if(p1 == s1) p1 = p1 + s1;      //if were also in greement last bar, then accumulate
      }
      
      if( s1 != s2 ) {                   // if s1 and s2 dont agree,
         agreement[i] = 0.0;             // indicate so, and do not accumulate persistanceSum[]        
      }
      
      if(s1*s2<0)   {                    // if aTrend and confirmation signal conflict and oppose, zero persistanceSum[]
         p1 = 0.0;
      }
      
      persistanceSum[i] = persistanceSum[i+1];
      if(p1 >=  2.0) persistanceSum[i] =  2.0;
      if(p1 <= -2.0) persistanceSum[i] = -2.0;
   }  
   return(0);
}

