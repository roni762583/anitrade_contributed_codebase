//+------------------------------------------------------------------+
//|                                         Aharon_5MAs_in_order.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue


//---- input parameters
extern int       MA1period=10;
extern int       MA2period=20;
extern int       MA3period=30;
extern int       MA4period=40;
extern int       MA5period=50;
extern int       MA6period=60;
extern int       MA7period=70;
extern int       MA8period=80;
extern int       MA9period=90;
extern int       MA10period=100;

extern string    symb="NULL";
extern int       timeframe=0;
extern int       ma_shift=0;
extern int       MAmethode=0;
/*
Constant Value Description 
MODE_SMA 0 Simple moving average, 
MODE_EMA 1 Exponential moving average, 
MODE_SMMA 2 Smoothed moving average, 
MODE_LWMA 3 Linear weighted moving average. 
*/

extern int    AppliedPrice=0;
/*
Constant Value Description 
PRICE_CLOSE 0 Close price. 
PRICE_OPEN 1 Open price. 
PRICE_HIGH 2 High price. 
PRICE_LOW 3 Low price. 
PRICE_MEDIAN 4 Median price, (high+low)/2. 
PRICE_TYPICAL 5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4.
*/

//---- buffers
double ExtMapBuffer1[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   
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
int start()   {
   int    counted_bars=IndicatorCounted();
   
   ///limit=Bars-counted_bars
//----
   for(int i = Bars; i<0; i--)   {
      /*
      if(iMA(symb, timeframe, MA1period, ma_shift, MAmethode, AppliedPrice, i) > iMA(symb, timeframe, MA2period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA2period, ma_shift, MAmethode, AppliedPrice, i) > iMA(symb, timeframe, MA3period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA3period, ma_shift, MAmethode, AppliedPrice, i) > iMA(symb, timeframe, MA4period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA4period, ma_shift, MAmethode, AppliedPrice, i) > iMA(symb, timeframe, MA5period, ma_shift, MAmethode, AppliedPrice, i) ) {
            ExtMapBuffer1[i] = 1;
         }
      if(iMA(symb, timeframe, MA1period, ma_shift, MAmethode, AppliedPrice, i) < iMA(symb, timeframe, MA2period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA2period, ma_shift, MAmethode, AppliedPrice, i) < iMA(symb, timeframe, MA3period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA3period, ma_shift, MAmethode, AppliedPrice, i) < iMA(symb, timeframe, MA4period, ma_shift, MAmethode, AppliedPrice, i) &&
         iMA(symb, timeframe, MA4period, ma_shift, MAmethode, AppliedPrice, i) < iMA(symb, timeframe, MA5period, ma_shift, MAmethode, AppliedPrice, i) ) {
            ExtMapBuffer1[i] = -1;
         }   */
      ExtMapBuffer1[i] = 0;    
   }
      
//----
   return(0);
}
//+------------------------------------------------------------------+