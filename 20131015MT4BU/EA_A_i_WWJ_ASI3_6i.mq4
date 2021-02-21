//+------------------------------------------------------------------+
//|                                         EA_A_i_WWJ_ASI3_6i.mq4 |
//|                        Copyright 2012, anitani Software Corp. |
//|                                        http://www.anitani.com  |
//+------------------------------------------------------------------+
//trades on ma of ma cross

#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"

extern int      SL = 250,
                TP = 250,
                ma1period = 3,
                ma1method = 2, //0-sma, 2-smoothed
                ma1price  = 5, //0-close, 1-open, 5-typical (H+L+C)/3 iMA
                ma2period = 3,
                ma2method = 2; 
extern bool     useSL = false,
                useTP = false;

double s1;

int start()  {

   s1 = iCustom(NULL, 0, "A_i_WWJ_ASI3_6i", 300, 0, 0); 
   
   if(isLongOnly() && s1==-1.0) closeAll();
   if(isShortOnly() && s1==1.0) closeAll();
   
   if(s1==1.0 && isFlat())  OrderSend(Symbol(), OP_BUY,  1, Ask, 3, buyStopLoss(), buyTakeProfit(), "test", 6718, 0, Green);
   if(s1==-1.0 && isFlat()) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", 6718, 0, Red);
   
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


bool isLongOnly()   {
   int totalOrders = 0, long = 0, short = 0;
   
   for(int i=0; i<OrdersTotal(); i++)   {                // loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);        // select order 
      if(OrderType()<2 && OrderMagicNumber() ==  6718) { // if open order (0-buy, 1-sell, other>1), and order from this EA magic number...
            if(OrderType()==0) long++;
            if(OrderType()==1) short++;
      } //close if(OrderType...
   } //close for loop
   if(long>=1 && short==0) return(true);
   return(false);
} //close function   
      



bool isShortOnly()   {
   int totalOrders = 0, long = 0, short = 0;
   
   for(int i=0; i<OrdersTotal(); i++)   {                // loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);        // select order 
      if(OrderType()<2 && OrderMagicNumber() ==  6718) { // if open order (0-buy, 1-sell, other>1), and order from this EA magic number...
            if(OrderType()==0) long++;
            if(OrderType()==1) short++;
      } //close if(OrderType...
   } //close for loop
   if(long==0 && short>=1) return(true);
   return(false);
} //close function



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