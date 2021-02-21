//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

static datetime lastTime;





int start()   {


   for(int i=0;i<OrdersTotal();i++)   { //scan open orders for magic and symbol matching
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      //if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      
      Print("OrderOpenTime()=", TimeToStr(OrderOpenTime(),TIME_SECONDS) );
      
   }//close for loop

   
   if(Time[0]!=lastTime) {
      //Print("yo",iCustom(NULL, 0, "Parabolic", 0, 0));
      lastTime =Time[0];
   }//close if(Time...


   return(0);
}



int init()   {
   return(0);
}


int deinit()   {
   return(0);
}