//+------------------------------------------------------------------+
//|                                                    AZ_Scalp1.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.metaquotes.net"

//---- input parameters
extern double    TP;
extern double    SL;
extern int       MA_Len;
extern int       ExtParam1;
extern int       ExtParam2;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   Comment("AZ_Scalp1 waiting for first tick...");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   static int start;
   static double bid;
   double t = start - GetTickCount();
   double p = bid - Bid;
   double v = p/t;
   
   Comment( "                                             ", "Time change", DoubleToStr( t, 16), "\n",
            "                                             ", "Price change ", DoubleToStr( p, 16), "\n",
            "                                             ", "Price/Time ", DoubleToStr( v, 16) );
   
   start = GetTickCount();
   bid = Bid;
//----
   return(0);
  }
//+------------------------------------------------------------------+