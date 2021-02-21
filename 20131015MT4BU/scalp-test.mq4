//+------------------------------------------------------------------+
//|                                                   scalp-test.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern double minProfit = 0.0;

extern int    entry     = 2;    //0 is buy, 1 is sell, 2 or more is random entry


int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}
  
  
  
int start()  {
   checkExit();
   if(flat()) enter();
   return(0);
}


void checkExit()  {
   double price;
   for(int i=0; i<OrdersTotal(); i++)  { //may need 1 instead of 0
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) break;
      if(OrderType()==0) price = Bid; //OP_BUY
      if(OrderType()==1) price = Ask; //OP_SELL
      if(OrderMagicNumber()==76258322 && OrderProfit()>minProfit ) OrderClose(OrderTicket(), OrderLots(), price, 3, Green);
   }
}


bool flat()  {      
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==76258322 && OrderType()<2) return(false); //if order from this: symbol, EA, & is open: ret. false 
   }//close for()
   return(true);
}


void enter() {
   int direction;
   double price; 
Print("hi from enter()");   
   if(entry==0) direction = 0; //buy
   if(entry==1) direction = 1; //sell
   if(entry>=2) {
      MathSrand(TimeLocal());
      int r = MathRand();
      if(r>16383.5) direction = 1;
      if(r<16383.5) direction = 0;
   }
   if(direction==0) price = Ask;
   if(direction==1) price = Bid;
   
   OrderSend(Symbol(), direction, 1.0, price, 3, 0, 0, "scalp-test", 76258322, 0, Red); //direction 0 is buy, 1 is sell
}