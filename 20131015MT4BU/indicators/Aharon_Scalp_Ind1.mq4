//+------------------------------------------------------------------+
//|                                            Aharon_Scalp_Ind1.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Aharon"
#property link      "aharon/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

double VelBuffer[100];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---
   SetIndexStyle(0,DRAW_LINE);
   
   IndicatorDigits(16);
   
   SetIndexBuffer(0,VelBuffer);
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
//----
   static int last_t = 0, tick_count = 0;
   static double last_bid = 0.0, vel_sum = 0.0;
   double t0 = 0.0, bid0 = 0.0, v = 0.0;
   
   t0 = GetTickCount();
   bid0 = Bid;
   tick_count =+ 1;
   
   v = (bid0 - last_bid) / (t0 - last_t) * 10000000;
   //  vel_sum = vel_sum + v;
   
   last_bid = bid0;
   last_t =t0;
   
   
   VelBuffer[tick_count] = v;
   
   /*
   for(int i = ArrayRange(VelBuffer, 0); i >= 0; i--) {
      VelBuffer[i-1] = VelBuffer[i + 2];
   }
   */
   return(0);
  }
//+------------------------------------------------------------------+


/////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+

