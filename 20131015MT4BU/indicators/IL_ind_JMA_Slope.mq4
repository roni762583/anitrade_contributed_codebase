//+------------------------------------------------------------------+
//|                                             IL_ind_JMA_Slope.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


#property indicator_buffers 1
#property indicator_color1 White
//#property indicator_color2 Blue
#property indicator_separate_window

extern int    Len     = 14,
              phase   = 0,
              BarCount= 300;
              
       double jmaslope[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,jmaslope);
   
   string s = "jmaslope()";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"jmaslope");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
    for(int i=250; i>=0; i--)  {
       jmaslope[i] = iCustom(NULL, 0, "jma", Len, phase, BarCount, 0, i) -
                     iCustom(NULL, 0, "jma", Len, phase, BarCount, 0, i+1);
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+