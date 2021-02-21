//+------------------------------------------------------------------+
//|                                                  aMedPrice.mq4 |

#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1  Blue


double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   
   SetIndexBuffer(0,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Median Price");
   SetIndexLabel(0,"Median");
   
   return(0);
  }
  

int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=0; i<limit; i++)
      SignalBuffer[i]= (High[i] + Low[i]) / 2 ;

   return(0);
  }
  

