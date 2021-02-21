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

//---- Global Vars
string Sym = "";
double BandWidth[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BandWidth);
   
   //---- name for DataWindow and indicator subwindow label
   string short_name="Bollinger BandWidth("+Periods+","+Deviation+")";
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
   if(counted_bars>=Periods) i=Bars-counted_bars-1;
   while(i>=0)
   {
     //----+
      // http://en.wikipedia.org/wiki/Bollinger_Bands
      // Formula as per the wikipedia site:
      // BandWidth = (upperBB - lowerBB) / middleBB
      
      double UpperBand = iBands(Sym,0,Periods,Deviation,Shift,0,MODE_UPPER, i );
      double LowerBand = iBands(Sym,0,Periods,Deviation,Shift,0,MODE_LOWER, i );
      double MiddlBand = iBands(Sym,0,Periods,Deviation,Shift,0,MODE_MAIN,  i );
      if( MiddlBand == 0.0 ) { MiddlBand = 0.00001; }
      
      BandWidth[i] = ( UpperBand - LowerBand ) / MiddlBand;
      //----
      i--;
   }
   //----
   return(0);
}
//+------------------------------------------------------------------+