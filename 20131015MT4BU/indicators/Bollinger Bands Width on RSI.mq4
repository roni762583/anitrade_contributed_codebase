//+-------------------------------------------------------------------+
//|                                           Bollinger BandWidth.mq4 |
//|                       Copyright © 2004, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.net |
//+-------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

//---- input parameters
extern int Periods=20;
extern int Deviation=2;
extern int Shift = 0;

extern int RSI_Periods = 14;

//---- Global Vars
string Sym = "";
double BandWidth[];
double Rsi[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
   //---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BandWidth);
   SetIndexBuffer(1,Rsi);
   
   //---- name for DataWindow and indicator subwindow label
   string short_name="Bollinger BandWidth on RSI("+Periods+","+Deviation+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   
   //----
   SetIndexDrawBegin(0,Periods);
   Sym = Symbol();

   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| Momentum                                                         |
//+------------------------------------------------------------------+
int start()
{
   int i,counted_bars=IndicatorCounted();
   
   //----
   if(Bars<=Periods) { return(0); }
   
   //---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=Periods;i++) 
      {
         BandWidth[Bars-i]=0.0;
      }
   }
   
   //----
   i=Bars-Periods-1;
   if(counted_bars>=Periods) { i=Bars-counted_bars-1; }
   
   //---- RSI
   for(int x = 0; x < Bars-1; x++ )
   {
      Rsi[x] = iRSI(Sym,0,RSI_Periods,PRICE_CLOSE,x);
   }
   
   //---- Bollinger Bands
   while(i>=0)
   {
     //----+
      // http://en.wikipedia.org/wiki/Bollinger_Bands
      // Formula as per the wikipedia site:
      // BandWidth = (upperBB - lowerBB) / middleBB
      
      double UpperBand = iBandsOnArray(Rsi,0,Periods,Deviation,Shift,MODE_UPPER,i);
      double LowerBand = iBandsOnArray(Rsi,0,Periods,Deviation,Shift,MODE_LOWER,i);
      double MiddlBand = iMAOnArray(Rsi,0,Periods,Shift,MODE_SMA, i);
      if( MiddlBand == 0.0 ) { MiddlBand = 0.00001; }
      
      BandWidth[i] = ( UpperBand - LowerBand ) / MiddlBand;
      //----
      i--;
   }
   //----
   return(0);
}
//+------------------------------------------------------------------+