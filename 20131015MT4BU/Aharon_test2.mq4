//+------------------------------------------------------------------+
//|                                                 Aharon_test2.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(!IsConnected())  {
      Alert("Not Connected!");
      //return(0);
   }
   
   Alert("Last Minute Tick Volume", "\n",
         "GBPUSDFXF ", iVolume("GBPUSDFXF", PERIOD_M1, 0) );
         
   start();      
         
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
int start()   {
//----
   for(int i=1; i<=OrdersTotal(); i++)   {                 // Loop through orders
      if (OrderSelect(i-1,SELECT_BY_POS)==true)   {        // If there is the next one
         Print("TimeCurrent()  : ", TimeCurrent(), " ,  OrderOpenTime()  ", OrderOpenTime());
      }
   }
//----
   return(0);
}
//+------------------------------------------------------------------+