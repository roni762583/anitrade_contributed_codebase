//+---------------------THIS IS IBFX VERSION---------------------------------------------+
//|                                   a_EA_consecutiveCorrection.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//test ea on 1 min. eurodollar
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int negThreshold = -10.0;
extern int posThreshold =  9.0;
extern double     lots  =  0.1;
extern int magic        =  7622588;
extern double sl        =  100.0;
extern double    TP        =  160;
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
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()   {
   double c, tp, SL;
   int ant;
   ant = -1 * negThreshold;
   
   c = iCustom(NULL, 0, "Aharon_Bands_on_Consecutive", 0, 1);
  
  //Print("c=",c);
     
  // if(!flat() && c == 0.0 ) flattenPrft();
   
   if( c < negThreshold && flat())   {
      if(sl!=0) SL=Bid-sl*Point;
      else SL=sl;
      tp = Ask+TP*Point;//(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      Print("tp for BUY =", tp);
      OrderSend(Symbol(),OP_BUY, lots, Ask, 3, SL, tp, "", magic, 0, CLR_NONE);
       
   }
   if( c > posThreshold && flat())   {
      if(sl!=0.0) SL=Ask+sl*Point;
      else SL=sl;
      tp = Bid-TP*Point;//(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      Print("tp for SELL =", tp);
      OrderSend(Symbol(),OP_SELL, lots, Bid, 3, SL, tp, "", magic, 0, CLR_NONE); 
   }
   return(0);
}

bool flat()   {
  int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() < 2) return(false);
  }
  return(true);
}

void flattenAll()   {
   //Print("hello from flattenAll()");
   double pri;
   int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() < 2) {
        if(OrderType()==0) pri = Bid; //if buy
        if(OrderType()==1) pri = Ask; //if buy
        OrderClose(OrderTicket(), OrderLots(), pri, 3, CLR_NONE);
     }
  }
}

/*
void flattenPrft()   {
   //Print("hello from flattenPrft()");
   double pri;
   int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() < 2) {
        if(OrderType()==0) pri = Bid; //if buy
        if(OrderType()==1) pri = Ask; //if buy
        if(OrderProfit()>=targetProfit) OrderClose(OrderTicket(), OrderLots(), pri, 3, CLR_NONE);
     }
  }
}
*/