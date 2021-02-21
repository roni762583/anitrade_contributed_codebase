//+-------------------------------------------------------------------+
//|                                            Bollinger Bands %b.mq4 |
//|                       Copyright © 2004, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.net |
//+-------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Red

//---- input parameters
extern int Periods=20;
extern int Deviation=2;
extern int Shift = 0;

extern int RSI_Periods = 14;

//---- Global Vars
string Sym = "";
double Main[];
double Upper[];
double Lower[];
double Rsi[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {  
   //---- indicator line
   SetIndexStyle(0,DRAW_LINE); SetIndexBuffer(0,Main);
   SetIndexStyle(1,DRAW_LINE); SetIndexBuffer(1,Upper);
   SetIndexStyle(2,DRAW_LINE); SetIndexBuffer(2,Lower);
   SetIndexStyle(3,DRAW_LINE); SetIndexBuffer(3,Rsi);
   
   //---- name for DataWindow and indicator subwindow label
   string short_name="Bollinger Bands on RSI";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   
   //----
   SetIndexDrawBegin(0,Periods+RSI_Periods);
   SetIndexDrawBegin(1,Periods+RSI_Periods);
   SetIndexDrawBegin(2,Periods+RSI_Periods);
   SetIndexDrawBegin(3,Periods+RSI_Periods);
   
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
         Main[Bars-i]=0.0;
         Upper[Bars-i]=0.0;
         Lower[Bars-i]=0.0;
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
     //----
      Upper[i] = iBandsOnArray(Rsi,0,Periods,Deviation,Shift,MODE_UPPER,i);
      Lower[i] = iBandsOnArray(Rsi,0,Periods,Deviation,Shift,MODE_LOWER,i);
      Main[i]  = iMAOnArray(Rsi,0,Periods,Shift,MODE_SMA, i);
      
      //----
      i--;
   }
   //----
   return(0);
}
//+------------------------------------------------------------------+