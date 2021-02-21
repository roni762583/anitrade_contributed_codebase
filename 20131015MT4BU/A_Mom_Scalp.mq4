//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#define MAGICMA  20050610

extern double Lots               = 0.1;
extern int    SL                 = 1000;
extern int    TP                 = 10;
extern double MaximumRisk        = 0.02;
extern int    mom                = 1;
extern int    LTF                = 60;
extern int    maxTime            = 360;
extern double DecreaseFactor     = 0;
extern double MovingPeriod       = 5;
extern double MovingShift        = 0;
extern int    ap                 = 1; //applied price 
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
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
//---- return lot size
   if(lot<0.1) lot=0.1;
   }
   return(lot);

}
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ma, m, m2;
   int    res;
//---- go trading only for first tiks of new bar
//   if(Volume[0]>1) return;
//---- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,ap,0);
   m = iMomentum(NULL, 0, mom, ap, 0);
   m2 = iMomentum(NULL, LTF, mom, ap, 0);
//---- sell conditions
   if(Open[0]<ma && m<100 && m2<100)  
     {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,getSL("s"),getTP("s"),"",MAGICMA,0,Red);
      return;
     }
//---- buy conditions
   if(Open[0]>ma && m>100 && m2>100)  
     {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,getSL("b"),getTP("b"),"",MAGICMA,0,Blue);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()  {

   double ma;
//---- go trading only for first tiks of new bar
//  if(Volume[0]>1) return;
//---- get Moving Average 
//   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
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
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
  }
//+------------------------------------------------------------------+

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