//+------------------------------------------------------------------+
//|                                         EA_maOfMaCrossMa.mq4 |
//|                        Copyright 2012, anitani Software Corp. |
//|                                        http://www.anitani.com  |
//+------------------------------------------------------------------+
//other orders in account from other source can cause error due to no-hedging rules
//add strailing stop, but for now test at fixed SL, TP

#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"

extern int      SL = 250,
                TP = 250;

extern bool     useSL = false,
                useTP = false;

double s1H = 0.0,
       s1D = -9.0;

int start()  {
   //"EA_maOfMaCrossMa" indicator works off of Open prices to eliminate mid-bar whipsaw 
   s1H = iCustom(NULL, 60, "maOfMaCrossMa", 20,PERIOD_H1,5,0,0,1,5,0,0, 0, 0); //ma of ma cross ma direction on hourly chart 
   s1D = iCustom(NULL, 1440, "maOfMaCrossMa", 20,PERIOD_D1,5,0,0,1,5,0,0, 0, 0); //ma of ma cross ma direction on daily chart
   Print("s1H = ", s1H, "      s1D = ", s1D);       
   //if major and minor trends dont agree close positions
   if(s1H != s1D) closeAll();//flatten all positions from this EA magic number
   
   //if major and minor trends agree and position is flat, then enter in direction of trend
   if(s1H == s1D && isFlat())   {
      if(s1H > 0.0) OrderSend(Symbol(), OP_BUY,  1, Ask, 3, buyStopLoss(), buyTakeProfit(), "test", 6718, 0, Green);
      if(s1H < 0.0) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", 6718, 0, Red);
   }//close if()
   
   return(0);
}


double buyStopLoss()   {
   if(useSL)  {
      return(Ask-SL*Point);
   }
   return(0);
}


double buyTakeProfit()   {
   if(useTP)  {
      return(Ask+TP*Point);
   }
   return(0);
}


double sellStopLoss()   {
   if(useSL)  {
      return(Bid+SL*Point);
   }
   return(0);
}


double sellTakeProfit()   {
   if(useTP)  {
      return(Bid-TP*Point);
   }
   return(0);
}



void closeAll() { //closes all open positions from this magic number
   double price = 0.0;                             //to hold order close price bid or ask 
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                            //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
            if(OrderType()==0)  price = Bid;
            if(OrderType()==1)  price = Ask;
            while(!OrderClose(OrderTicket(), OrderLots(), price, 3, Blue)) { //loop till OrderClose() succeeds
               Print("order close failed with error code ", GetLastError(), "  ...retrying"); //print error code
               Alert("order close failed...retrying"); //send alert 
            } //closes while loop 
            // at this point OrderClose() will have succeeded
      }// close if(OrderType...
   }//close for loop
}//close closeAll()   


bool isFlat()  { //will return true if no open orders from this EA magic - ignores other orders in system, ignores pending and historical orders 
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
            totalOrders++;
         }//close if(OrderSelect...
   }//close for loop
   //Print(" from isFlat(): totalOrders = ", totalOrders);
   if(totalOrders==0) return(true);
   return(false);
}//close isFlat()


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
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