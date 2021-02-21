//+------------------------------------------------------------------+
//|                                        a_EA_correction_on_bb.mq4 |
//|                      Copyright © 2011, Anitani    Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//this ea sells on price exceeding bb based on Hi, Buys on price below bb based on Lo, and flattens all on profit setting
//this version allows sl, tp
//this version confirms entry with bolinger bands
#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.Anitani.com"

extern int mal = 2;
extern int maMethod = 0;
//extern int XSpips = 7;
extern int magic        =  7622588;
extern double targetProfit = 20.0;
extern double sl = 140.0, tp = 18.0;


double smaH, smaL, smaM, ubb, lbb;
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
   
   
   double c, TP, SL;
   //int ant;
   RefreshRates();
   
   smaH = iMA(NULL, 0, mal, 0, maMethod, PRICE_HIGH, 0);
   smaL = iMA(NULL, 0, mal, 0, maMethod, PRICE_LOW, 0);
   smaM = iMA(NULL, 0, mal, 0, maMethod, PRICE_MEDIAN, 0);
   ubb = iBands(NULL, 0, 20, 2, 0, PRICE_HIGH, MODE_UPPER, 0);
   lbb = iBands(NULL, 0, 20, 2, 0, PRICE_LOW, MODE_LOWER, 0);
     
   if(!flat() && Bid<smaM && Ask>smaM) flattenPrft(); //if reach median flatten
   
   if(flat() &&  Ask<lbb)  {
      //sl = 0;//Bid-(MathMax((iATR(NULL, 0, ant, 0)/2.0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
     // tp = 0;// Ask+(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      if(sl!=0) SL=NormalizeDouble(Bid-sl*Point,Digits);
      else SL = sl;
      if(tp!=0) TP=NormalizeDouble(Ask+tp*Point,Digits);
      else TP=tp;
      Print("hi from buy, sl=", SL, "  ,tp=", TP);
      OrderSend(Symbol(),OP_BUY, 0.1, Ask, 3, SL, TP, "", magic, 0, CLR_NONE);  
   }
   
   if(flat() && Bid>ubb)  {
      //sl = 0;// Ask+(MathMax((iATR(NULL, 0, ant, 0)/2.0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
     // tp = 0;// Bid-(MathMax(iATR(NULL, 0, 14, 0),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point);
      if(sl!=0) SL=NormalizeDouble(Ask+sl*Point,Digits);
      else SL = sl;
      if(tp!=0) TP=NormalizeDouble(Bid-tp*Point,Digits);
      else TP=tp;
      Print("hi from sell, sl=", SL, "  ,tp=", TP);
      OrderSend(Symbol(),OP_SELL, 0.1, Bid, 3, SL, TP, "", magic, 0, CLR_NONE); 
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


void flattenPrft()   {
   //Print("hello from flattenPrft()");
   double pri;
   int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() < 2) {
        if(OrderType()==0) pri = Bid; //if buy
        if(OrderType()==1) pri = Ask; //if sell
        if(OrderProfit()>=targetProfit) OrderClose(OrderTicket(), OrderLots(), pri, 3, CLR_NONE);
     }
  }
}

