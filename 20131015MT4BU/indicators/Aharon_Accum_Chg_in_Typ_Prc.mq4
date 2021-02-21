//+------------------------------------------------------------------+
//|                                  Aharon_Accum_Chg_in_Typ_Prc.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon."
#property link      "http://www.anitani.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters


//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
///////////////////////////////////////////////////////

         short_name="Accum_chg_typ";
     
   IndicatorShortName(short_name);
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   sma();
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   
   for(i=1;i<MA_Period;i++,pos--)
   sum+=Close[pos];                       //sum+=Close[pos];     az
//---- main calculation loop
   while(pos>=0)
     {
      sum+=price[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=price[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }

