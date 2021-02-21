//  AZ_eFs.mq4
// take slope[pip/min] * period  and relate to TP
// take 1 / slope[pip/min] * TP to get time expiration of order 

#define MAGICMA  762583

extern double Lots               = 0.1;
extern int    SL                 = 1000;
extern int    TP                 = 10;

extern double MaximumRisk        = 0.02;

extern int    Period1            = 4; 
extern int    Taps               = 21;
extern int    Window             = 4; 
 
extern int    OTF                = 15;
extern int    maxTime            = 2000;

extern double DecreaseFactor     = 0;

int p;


//+------------------------------------------------------------------+
//| init() function                                                  |
//+------------------------------------------------------------------+
void init()   {
   p = Period();
}


//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()  {
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
}


//+------------------------------------------------------------------+
//| CalculateCurrentOrders()                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)   {
   int buys=0,sells=0;

   for(int i=0;i<OrdersTotal();i++)     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)   {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
      }
   }

   if(buys>0) return(buys);
   else       return(-sells);
}


//+------------------------------------------------------------------+
//| CheckForOpen()                                                   |
//+------------------------------------------------------------------+
void CheckForOpen()   {
   double signal0, signal1, signalLTF;
   int    res;

   // Trading criteria
   signal0   = iCustom(NULL, 0, "Aharon_eFs_C2",  Period1, Taps, Window, OTF, 2, 0);
   /*signal1   = iCustom(NULL, 0, "Aharon_eFslope_HL",  Period1, Taps, Window, 1, 1);
   signalLTF = iCustom(NULL, LTF, "Aharon_eFslope_HL",  Period1, Taps, Window, 1, 0);*/
   
   //---- go trading only for first tiks of new bar
   //   if(Volume[0]>1) return;

   //---- sell conditions
   if(signal0==-1.0)   {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,getSL("s"),getTP("s"),"",MAGICMA,0,Red);      
      return;
   }
   
   //---- buy conditions
   if(signal0==1.0)   {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,getSL("b"),getTP("b"),"",MAGICMA,0,Blue);
      return;
   }
}


//+------------------------------------------------------------------+
//| CheckForClose()                                                  |
//+------------------------------------------------------------------+
void CheckForClose()  {
   double ma;
   //---- go trading only for first tiks of new bar
   //  if(Volume[0]>1) return;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      if(OrderType()==OP_BUY)
        {//if order is old by max min. 
         if(TimeCurrent()-OrderOpenTime()> maxTime) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
        
      if(OrderType()==OP_SELL)
        {
         if(TimeCurrent()-OrderOpenTime()> maxTime) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
        }
     }

   return;
}



//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()  {
   double lot =Lots;
if(Lots <= 0){
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }

   if(lot<0.1) lot=0.1;
   }
   return(lot);

}





double getSL(string type)   {
   double sl;
   if(type == "b" || type == "B") {//sl for buy order 
      sl = Ask - SL*Point;
   }
   if(type == "s" || type == "S") {//sl for sell order 
      sl = Bid + SL*Point;
   }
   return(sl);
}

double getTP(string type)   {
   double tp;
   if(type == "b" || type == "B") {//tp for buy order 
      tp = Ask + TP*Point;
   }
   if(type == "s" || type == "S") {//tp for sell order 
      tp = Bid - TP*Point;
   }
   return(tp);
}