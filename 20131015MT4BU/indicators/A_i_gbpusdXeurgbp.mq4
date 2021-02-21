//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//to ompare eurusd to (gbp/usd)(eur/gbp)
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 1
#property  indicator_color1  Silver
//#property  indicator_color2  Red
//#property  indicator_width1  2
//---- indicator parameters
//extern int FastEMA=12;
//extern int SlowEMA=26;
//extern int SignalSMA=9;
//---- indicator buffers
double     derive[];
double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
 //  SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,10);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,derive);
 //  SetIndexBuffer(1,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("xxx");
   SetIndexLabel(0,"derive");
 //  SetIndexLabel(1,"Signal");
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

   string Sym = Symbol();
   Print(Sym);
   for(int i=0; i<limit; i++)    derive[i]=iClose("GBPUSD", 0, i) * iClose("EURGBP", 0, i) - iClose("EURUSD", 0, i);

  // for(i=0; i<limit; i++)     SignalBuffer[i]=iClose("EURUSD", 0, i);

   return(0);
  }
//+------------------------------------------------------------------+