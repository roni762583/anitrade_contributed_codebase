//+------------------------------------------------------------------+
//|                                         kalman filter simple2.mq4 |
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

static double   kH40, kH41, kM11, majorTrend, pmajorTrend, minorTrend, pminorTrend,
                dup     = 0.0,
                ddn     = 0.0, //to hold kalman filter value
                dir     = 9.0, //this is direction up is 1.0, down is -1.0, 9.0 is neither - initialized
                lastDir = 9.0, //to store last direction
                cd      = 9.0; //to store current position directio
       
       bool     newBar = false; //flag when new bar is started
                
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()  {
//----if 4H kalman direction is up, take trades in 1M inup direction when 1M kalman matches up, and vise versa. Later add trailing stop
//kalman set to use Open price to prevent whipsaw in middle of bar 
   kH40 = iCustom(NULL, PERIOD_H4, "kalman filter", 1, 1.0, 1.0, 500, 0, 0); //kalman H4 current bar 
   kH41 = iCustom(NULL, PERIOD_H4, "kalman filter", 1, 1.0, 1.0, 500, 0, 1); //kalman H4 previous bar 
   
   kM11 = iCustom(NULL, PERIOD_M1, "kalman filter", 1.0, 1.0, 500, 0, 0, 1); //kalman M1 previous bar 
   //extract major trend
   if(kH40>0 && kH40<9999 && kH41>0 && kH41<9999) majorTrend = 1.0; //if current and prev. bars are up and not over flowed, indicator is up
   if(kH40>9999 && kH41>9999) majorTrend = -1.0; //if current and prev. bars are overflowed, indicator is down
   
   //extract minor trend
   if(kM11>0 && kM11<9999) minorTrend = 1.0; //positive but not overflow is up
   if(kM11>9999) minorTrend = -1.0; //overflow condition indicates downtrend
   
   //detect if major trend changed and stable for two bars 
   if(pmajorTrend!=majorTrend)  {
      pmajorTrend = majorTrend; //set pmajorTrend to current trend
      closeAll();//flatten all positions
      Print("New majorTrend = ", majorTrend);//
   }
   
   //detect if minor trend changed 
   if(pminorTrend!=minorTrend)  {
      pminorTrend = minorTrend; //set pmajorTrend to current trend
      //alert if new minor trend matches major trend
      if(minorTrend==majorTrend)   {
         Print("minorTrend matches majorTrend= ", minorTrend, "   time=", TimeToStr(Time[1],TIME_MINUTES));//
         if(isFlat()) {
           if(minorTrend==1.0)  OrderSend(Symbol(), OP_BUY,  1, Ask, 3, buyStopLoss(), buyTakeProfit(), "test", 6718, 0, Green);
           if(minorTrend==-1.0) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", 6718, 0, Red);
        }
      }
   }
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



void closeAll() {
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
   Print("isFlat() totalOrders = ", totalOrders);
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