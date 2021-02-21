//+------------------------------------------------------------------+
//|                                              AZ    escape100.mq4 |
//|                                    Copyright © 2009, OGUZ BAYRAM |
//|                                            es_cape77@hotmail.com |
//+------------------------------------------------------------------+
//prevent it from trading during trending times, try adx indicator 
//and stop it from trading when hitting X many cosecutive losses
//in ver100, changed trading criteria < to > and vise versa
extern double lTakeProfit   = 19;
extern double sTakeProfit   = 19;
extern double lStopLoss     = 200;
extern double sStopLoss     = 200;
extern color  clOpenBuy     = Green;
extern color  clOpenSell    = Red;
extern string Name_Expert   = "escape100";
extern int    Slippage      = 1;
extern bool   UseSound      = false;
extern string NameFileSound = "Alert.wav";
extern double Lots          = 0.1;
extern int    maxOrders     = 0;

extern int    CosecLossMax  = 100;

extern int    CBShft        = 0;
extern int    CSShft        = 0;
extern int    MaPeriodB     = 25; 
extern int    MaPeriodS     = 50;
extern int    MaShftB       = 1;
extern int    MaShftS       = 1;

bool EAoff;                                                //switch off
int    TF;                                                 //time frame


void deinit() {
}


int init()  {
  TF     = Period();
  EAoff  = false;
}


int start()   {
   if(EAoff)   {
      Alert("Reached Max. cosecutive losses, EA is OFF");
      return;
   }
   
   if(Bars<50){
      Print("bars less than 50");
      return(0);
   }
   if(lTakeProfit<1){
      Print("TakeProfit less than 1");
      return(0);
   }
   if(sTakeProfit<1){
      Print("TakeProfit less than 1");
      return(0);
   }

   double CB  = iClose(NULL, TF, CBShft);
   double MaB = iMA(NULL, TF, MaPeriodB, 0, MODE_SMA, PRICE_OPEN, MaShftB);
   double CS  = iClose(NULL,TF,CSShft);
   double MaS = iMA(NULL, TF, MaPeriodS, 0, MODE_SMA, PRICE_OPEN, MaShftS);

   if(AccountFreeMargin()<(500*Lots)){
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
   
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
   for(int i=orders-1;i>=0;i--)   {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
   }
   
   if(losses>CosecLossMax) EAoff = True;                   //if reached maximum consecutive losses, turn EA off
      
   if (!ExistPositions())   {                              //keep entering positions 'till reaching maximum allowed
      
      if ((CB > MaB && MaB>MaS))   {                            //open Buy position
         CloseSell();
         OpenBuy();
         return(0);
      }

      if ((CS<MaB && MaB<MaS))   {                            //open Sell position
         CloseBuy();
         OpenSell();
         return(0);
      }
   }
   
   return (0);
}


bool ExistPositions()  {                                   //keep entering positions 'till reaching maximum allowed
   for (int i=maxOrders; i<=OrdersTotal(); i++)  {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol()==Symbol()) {
            return(True);                                  //True gets fliped to False, and no new orders generated
         }
      } 
   } 
   return(false);
}


void OpenBuy() { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 
   ldLot = GetSizeLot(); 
   ldStop = GetStopLossBuy(); 
   ldTake = GetTakeProfitBuy(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(), OP_BUY, ldLot, Ask, Slippage, ldStop, ldTake, lsComm, 0, 0, clOpenBuy); 
   if (UseSound) PlaySound(NameFileSound); 
} 


void OpenSell() { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 

   ldLot = GetSizeLot(); 
   ldStop = GetStopLossSell(); 
   ldTake = GetTakeProfitSell(); 
   lsComm = GetCommentForOrder(); 
   OrderSend(Symbol(), OP_SELL, ldLot, Bid, Slippage, ldStop, ldTake, lsComm, 0, 0, clOpenSell); 
   if (UseSound) PlaySound(NameFileSound); 
} 

void CloseBuy()   {
   int    orders=OrdersTotal();     // history orders total
   for(int i=0; i>=orders; i++)   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_BUY) continue;
         //----
            OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
   }
}

void CloseSell()   {
   int    orders=OrdersTotal();     // history orders total
   for(int i=0; i>=orders; i++)   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
            OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Yellow);
   }
}

string GetCommentForOrder() { return(Name_Expert); } 


double GetSizeLot() { return(Lots); } 


double GetTakeProfitBuy() { return(Ask+lTakeProfit*Point); } 


double GetTakeProfitSell() { return(Bid-sTakeProfit*Point); }


double GetStopLossBuy() { return(Bid-lStopLoss*Point); }


double GetStopLossSell() { return(Ask+sStopLoss*Point); }