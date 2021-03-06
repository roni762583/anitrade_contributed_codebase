//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright � 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  2
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern double percentcorrection = 0.95; //percent in decimal form ofreceding from extremum
static double extremum;
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
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
   for(i=0; i<limit; i++)  {
      double a = iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
      double b = 0.0;
      if(MacdBuffer[i]>0 && a>0 && MacdBuffer[i]>a) b =  1.0;
      if(MacdBuffer[i]<0 && a<0 && MacdBuffer[i]<a) b = -1.0;
      SignalBuffer[i] = b;
   }   
   
   for(i=limit; i>0; i--)  {
      if(MacdBuffer[i]>0 && MacdBuffer[i]>MacdBuffer[i+1]) if(MacdBuffer[i]>extremum) extremum = MacdBuffer[i];  //going up
      if(MacdBuffer[i]<0 && MacdBuffer[i]<MacdBuffer[i+1]) if(MacdBuffer[i]<extremum) extremum = MacdBuffer[i];  //going down
      
      if(MacdBuffer[i]>0 && MacdBuffer[i]<percentcorrection*extremum) SignalBuffer[i] = 0.0; //positive and lost percent of max
      if(MacdBuffer[i]<0 && MacdBuffer[i]>percentcorrection*extremum) SignalBuffer[i] = 0.0; //negative and lost percent of min
   }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+