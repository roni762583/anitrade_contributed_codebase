//+------------------------------------------------------------------+
//|                                        a_EA_correction_on_ma.mq4 |
//|                      Copyright © 2011, Anitani    Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//this ea sells on price exceeding sma(3)Hi, Buys on price below sma()Lo, and flattens all on price in smaMidian
#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.Anitani.com"

extern int mal = 3;
//extern int posThreshold =  9.0;
extern int magic        =  7622588;
//extern double targetProfit = 10.0;

double smaH, smaL, smaM;
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
   double c, tp, sl;
   //int ant;
   RefreshRates();
   
   smaH = iMA(NULL, 0, mal, 0, 0, PRICE_HIGH, 0);
   smaL = iMA(NULL, 0, mal, 0, 0, PRICE_LOW, 0);
   smaM = iMA(NULL, 0, mal, 0, 0, PRICE_MEDIAN, 0);
     
   if(!flat() && Bid<smaM && Ask>smaM) flattenAll(); //if reach median flatten
   
   if(flat() && Ask<smaL)  {
      sl = 0;//Bid-(MathMax((iATR(NULL, 0, ant, 0)/2.0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      tp = 0;// Ask+(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      //Print("tp for BUY =", tp);
      OrderSend(Symbol(),OP_BUY, 0.1, Ask, 3, sl, tp, "", magic, 0, CLR_NONE);  
   }
   
   if(flat() && Bid>smaH)  {
      sl = 0;// Ask+(MathMax((iATR(NULL, 0, ant, 0)/2.0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      tp = 0;// Bid-(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      //Print("tp for SELL =", tp);
      OrderSend(Symbol(),OP_SELL, 0.1, Bid, 3, sl, tp, "", magic, 0, CLR_NONE); 
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