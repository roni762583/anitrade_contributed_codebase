//+------------------------------------------------------------------+
//|                                                  aPeaks.mq4 |
// calculates mov. avg. of median price to smooth, then inflection point in curve to identify peak/valey and return close price 
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  White

static     double     sum = 0.0;

double     SignalBuffer[], Peaks[];


extern int len = 5; //length of ma

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   
   IndicatorDigits(Digits);
//---- indicator buffers mapping
   
   SetIndexBuffer(0,SignalBuffer);  //SignalBuffer
   SetIndexBuffer(1,Peaks);  //SignalBuffer
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Peaks");
   SetIndexLabel(0,"SignalBuff.");
   SetIndexLabel(1,"Peaks");
   

   return(0);
  }
  

int start()   {
   
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=0; i<limit; i++)   {
      sum = 0.0;
      for(int j=0; j<len; j++)   {
         sum = sum + ((High[i+j]+Low[i+j])/(2));  
      }
      SignalBuffer[i] = sum / len;
   }   
   
   for(i=0; i<limit; i++)   {
      Peaks[i+1] = 0.0;
      if( SignalBuffer[i] > SignalBuffer[i+1] && SignalBuffer[i+1] <= SignalBuffer[i+2])   Peaks[i+1] = -Close[i+1];
      if( SignalBuffer[i] < SignalBuffer[i+1] && SignalBuffer[i+1] >= SignalBuffer[i+2])   Peaks[i+1] =  Close[i+1];
   }
   
   return(0); 
}
  

