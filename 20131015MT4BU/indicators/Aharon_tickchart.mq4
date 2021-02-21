//+------------------------------------------------------------------+
//|                                             Aharon_tickchart.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.metaquotes.net"


#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 Green

double ATRBuffer[];
double SpreadBuffer[];
double AboveBelowMABuffer[];

int i_count = 50;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
string short_name;
//---- 
   IndicatorBuffers(3);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(0,ATRBuffer);
   SetIndexBuffer(1,SpreadBuffer);
   SetIndexBuffer(2,AboveBelowMABuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="Aharon_Scalper_Tool";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ATR");
   SetIndexLabel(1,"Spread");
   SetIndexLabel(2,"AboveBelowMA");
//----
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(2,0);
//----
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
   //Alert("counted_bars = ", counted_bars);
   
   
   ATRBuffer[0] = iATR(NULL, 0, 1, 0);
   SpreadBuffer[0] = Ask-Bid;
   if(Open[0] > iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0)) AboveBelowMABuffer[0] = 0.0005;
   if(Open[0] < iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0)) AboveBelowMABuffer[0] = -0.0005;
   
     //is ATR bigger than spread? yes- pos. value
   /*
   AskBuffer[0]=Ask;
   BidBuffer[0]=Bid;
   
   for(int i = 0; i <= i_count; i++)  {  //for shifting all data back by one bar
      AskBuffer[i+1]=AskBuffer[i];
      BidBuffer[i+1]=BidBuffer[i];
   }  */
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+