//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_color3  White

#property  indicator_width1  2
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern double factor = 0.75;
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[];
double     s[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,s);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"s");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
//---- signal line counted in the 3-rd buffer
   for(i=0; i<limit; i++)   {
      double a = 0.0;
      if(MacdBuffer[i]>0 && 
         SignalBuffer[i]>0 &&
         MacdBuffer[i]>SignalBuffer[i] && 
         MacdBuffer[i]>=factor*MacdBuffer[i+1]) a =  1.0;
         
      if(MacdBuffer[i]<0 && 
         SignalBuffer[i]<0 &&
         MacdBuffer[i]<SignalBuffer[i] && 
         MacdBuffer[i]<=factor*MacdBuffer[i+1]) a = -1.0;
      s[i]= a;
   }
   bool d =true;
   for(i=limit; i>=0; i--)   {
     
      if(s[i] ==  1.0) d = true;
      if(s[i] == -1.0) d = false;
   }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+