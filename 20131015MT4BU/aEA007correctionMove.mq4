//+------------------------------------------------------------------+
//|                                         aEA007correctionMove.mq4 |
//|                      Copyright © 2011, Anitani Software Corp.    |
//|                                        http://www.anitani.com    |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.anitani.com"
extern double      upperThshldBarOutBB = 30.0;
extern double      lowerThshldBarOutBB = -30.0;
extern double      lTakeProfit = 6;
extern double      sTakeProfit = 6;
extern double      lStopLoss   = 100;
extern double      sStopLoss   = 100;
extern int         x           = 1;
extern color       clOpenBuy   = Green;
extern color       clOpenSell  = Red;
extern string      Name_Expert = "aEA007correctionMove";
extern int         magic       = 7622523;
extern int         Slippage = 3;
extern bool        UseSound = false;
extern string      NameFileSound = "Alert.wav";
extern double      Lots = 0.1;

double             s1, s2, s3, s4;

void deinit() {
   Comment("");
}


int start(){
   if(Bars<50){
      Print("bars less than 50");
      return(0);
   }//close if()
   
   //set signals
   if(   iCustom(NULL, 0, "Aharon_Bands_on_Range", 0, 1) > iCustom(NULL, 0, "Aharon_Bands_on_Range", 1, 1)   ) s1 = 1.0; //is range out of BB
   else s1 = 0.0;
   
   s2 = 0.0;
   if(iCustom(NULL, 0, "A_i_percenOfBarOutOfBB", 50, 0, 1) > upperThshldBarOutBB) s2 = 1.0;
   if(iCustom(NULL, 0, "A_i_percenOfBarOutOfBB", 50, 0, 1) < lowerThshldBarOutBB) s2 = -1.0;
   
   
   s3 = iCustom(NULL, 0, "A_i_upOrdnBar", 180, 0, 1);

   if(AccountFreeMargin()<(500*Lots)) {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }//close if()
   
   if (!ExistPositions())   {

      if(s1 == 1.0 && s2 == 1.0 && s3 == 1.0)  {
         OpenBuy();
         return(0);
      }//close if()

      if(s1 == 1.0 && s2 == -1.0 && s3 == -1.0)  {
         OpenSell();
         return(0);
      }//close if()
   }// close if()
   
   return (0);
}// close start()


bool ExistPositions() {
   for (int i=x; i<OrdersTotal(); i++) {  //should only return false if open/pending orders are greater than x
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol()==Symbol() && OrderMagicNumber() == magic) {
            return(True);
         }
      } 
   } 
   return(false);
}

void OpenBuy() { 
   double ldLot, ldStop, ldTake; 
   
   ldLot = GetSizeLot(); 
   ldStop = GetStopLossBuy(); 
   ldTake = GetTakeProfitBuy(); 
   
   OrderSend(Symbol(),OP_BUY,ldLot,Ask,Slippage,ldStop,ldTake,"",magic,0,clOpenBuy); 
   if (UseSound) PlaySound(NameFileSound); 
}

 
void OpenSell() { 
   double ldLot, ldStop, ldTake; 

   ldLot = GetSizeLot(); 
   ldStop = GetStopLossSell(); 
   ldTake = GetTakeProfitSell(); 
   
   OrderSend(Symbol(),OP_SELL,ldLot,Bid,Slippage,ldStop,ldTake,"",magic,0,clOpenSell); 
   if (UseSound) PlaySound(NameFileSound); 
} 


double GetSizeLot() { 
   return(Lots); 
} 


double GetTakeProfitBuy() { 
   return(Ask+lTakeProfit*Point);
}


double GetTakeProfitSell() { 
   return(Bid-sTakeProfit*Point);
}


double GetStopLossBuy() { 
   return(Bid-lStopLoss*Point);
}


double GetStopLossSell() {
   return(Ask+sStopLoss*Point);
}