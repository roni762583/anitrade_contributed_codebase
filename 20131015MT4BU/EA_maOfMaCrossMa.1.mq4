//+------------------------------------------------------------------+
//|                                         EA_maOfMaCrossMa.1.mq4 |
//|                        Copyright 2012, anitani Software Corp. |
//|                                        http://www.anitani.com  |
//+------------------------------------------------------------------+
//other orders in account from other source can cause error due to no-hedging rules
//add strailing stop, but for now test at fixed SL, TP

#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"

extern int      TF1             = 60,
                TF2             = 1440,
                SL              = 250,
                TP              = 250;

extern bool     useSL           = false,
                useTP           = false;

static datetime lastBarOpenTime; //to work with IsNewBar()

double          AoA_TF1         = 0.0, //SMA(5) of SMA(5) of Open prices calculated for bar zero (looks like binomial structure).
                A_TF1           = 0.0, //SMA(5) of Open prices calculated for bar zero.
                AoA_TF2         = 0.0, //same as AoA_TF1, but for TF2
                A_TF2           = 0.0, //same as A_TF1, but for TF2
                dir_TF1         = 0.0, //to hold trend direction on TF1
                dir_TF2         = 0.0; //on TF2


int start()  {
   if(IsNewBar())   {
      
      ////////    this block calcultaes SMA(5), and SMA(5)-of-SMA(5), on Open prices on TimeFrame 1, and 2     //////////////////
                                                                                                                               //
      AoA_TF1 = (iOpen(NULL, TF1, 0)+2*iOpen(NULL, TF1, 1)+3*iOpen(NULL, TF1, 2)+4*iOpen(NULL, TF1, 3)+5*iOpen(NULL, TF1, 4)+  //(looks like binomial structure)
                 4*iOpen(NULL, TF1, 5)+3*iOpen(NULL, TF1, 6)+2*iOpen(NULL, TF1, 7)+iOpen(NULL, TF1, 8))/25.00000;              //
                                                                                                                               //
      A_TF1   = (iOpen(NULL, TF1, 0)+iOpen(NULL, TF1, 1)+iOpen(NULL, TF1, 2)+iOpen(NULL, TF1, 3)+iOpen(NULL, TF1, 4))/5.00000; //
                                                                                                                               //
                                                                                                                               //
                                                                                                                               //
      AoA_TF2 = (  iOpen(NULL, TF2, 0) + 2*iOpen(NULL, TF2, 1) + 3*iOpen(NULL, TF2, 2) + 4*iOpen(NULL, TF2, 3) +               //
                 5*iOpen(NULL, TF2, 4) + 4*iOpen(NULL, TF2, 5) + 3*iOpen(NULL, TF2, 6) + 2*iOpen(NULL, TF2, 7) +               //
                   iOpen(NULL, TF2, 8)  ) / 25.00000;                                                                          //
                                                                                                                               //
      A_TF2   = (iOpen(NULL, TF2, 0)+iOpen(NULL, TF2, 1)+iOpen(NULL, TF2, 2)+iOpen(NULL, TF2, 3)+iOpen(NULL, TF2, 4))/5.00000; //
                       //  Print("AoA_TF1 = ", AoA_TF1,",  AoA_TF2 = ", AoA_TF2);                                              //
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
      //now, for each TF, compare the SMA with the SMA-of-SMA for trend direction at the respectice TF
      dir_TF1 = 0.0;                       //zero out var
      dir_TF2 = 0.0;
      
      if(A_TF1 > AoA_TF1) dir_TF1 =  1.0;  //dir is up (avg of avg should lag)
      if(A_TF1 < AoA_TF1) dir_TF1 = -1.0;  //dir is down
      
      if(A_TF2 > AoA_TF2) dir_TF2 =  1.0;  //dir is up (avg of avg should lag)
      if(A_TF2 < AoA_TF2) dir_TF2 = -1.0;  //dir is down
      
      //check for indefinate condition and get out
      if(dir_TF1==0.0 || dir_TF2==0.0)   {
         Print("indefinate condition: dir_TF1=", dir_TF1, "   dir_TF2=", dir_TF2, "   occured at: ", TimeToStr(Time[0],TIME_DATE|TIME_MINUTES) );
         return(0); //on at least one TF, SMA equals SMA-of-SMA, i.e. no definate direction
      }
      
      //if major and minor trends dont agree close positions
      if(dir_TF1 != dir_TF2)   {
         //Print("trend direction differs between TFs: dir_TF1 = ", dir_TF1, ", while dir_TF2 = ", dir_TF2);
         closeAll(); //flatten all positions from this EA magic number
      }
      
      //check if for some strange reason both TFs have same dir, but open position is in wrong direction
      if(dir_TF1 == dir_TF2 && !isFlat())   {
         if(dir_TF1 != longOrShort())   {
            Print("something wrong: both TFs point opposite direction of open position!");
            closeAll(); //flatten all positions from this EA magic number
         }
      }
      
      
      //if both TF's have same trend direction, and position is flat, enter order in trend direction
      if(dir_TF1 == dir_TF2 && isFlat())   {
         //Print("dir_TF1 = ", dir_TF1, ", and dir_TF2 = ", dir_TF2, "  right b4 sending order");
         if(dir_TF1 > 0.0) OrderSend(Symbol(), OP_BUY,  1, Ask, 3, buyStopLoss(), buyTakeProfit(), "test", 6718, 0, Green);
         if(dir_TF1 < 0.0) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", 6718, 0, Red);
      }//close if(dir_TF1 == dir_TF2 &&....
      
      //Print("AoA_TF1=", AoA_TF1, "    A_TF1=", A_TF1);
   }//closes if(IsNewBar()...
   
   return(0);
   
} //close start()



//function to detect new bar formed
//datetime lastBarOpenTime; //this is moved to top with other variables
bool IsNewBar()   {
   datetime thisBarOpenTime = Time[0];
   if(thisBarOpenTime != lastBarOpenTime) {
      lastBarOpenTime = thisBarOpenTime;
      return (true);
   }//close if()...
   else
   return (false);
}//close IsNewBar()...





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


double longOrShort()   {
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
            if(OrderType()==0) return(1.0);
            if(OrderType()==1) return(-1.0);
      }//close if(OrderType...      
   }//close for loop
}//close longOrShort()


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