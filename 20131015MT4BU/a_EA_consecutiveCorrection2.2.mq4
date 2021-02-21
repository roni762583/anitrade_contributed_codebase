//+------------------------------------------------------------------+
//|                                a_EA_consecutiveCorrection2.2.mq4 |
//|                      Copyright © 2011, Anitani Software Corp. |
//|                                        http://www.ANITANI.COM    |
//+------------------------------------------------------------------+
// this version will implement the idea of prev. versions without calling the iCustom indicator function
// idea that the more consecutive bars that are of the same direction the more likely the next bar to be of opposite direction
#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.anitani.com"

extern int consecBars    = 4;
extern double     lots  =  0.1;
extern int magic        =  7654228;
extern double sl        =  100.0;
extern int    TP        =  160;

static int   cntr = 0;
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
   double tp, SL;
   
   cntr = 0;
   
   for(int i = 1; i<=consecBars; i++)  {  //for up bars 
   Print("sell i=",i);
      if(Close[i]>Open[i]) cntr = cntr + 1;
   }         //close for i ...
   if(cntr == consecBars && flat())   {
      SL=Ask+sl*Point;
      tp = Bid-TP*Point;
      OrderSend(Symbol(),OP_SELL, lots, Bid, 3, SL, tp, "", magic, 0, Red);
   }        //close if cntr for up bars 
   
   
   cntr = 0;
   for(i = 1; i<=consecBars; i++)  {  //for down bars 
      if(Close[i]<Open[i]) cntr = cntr + 1;
   }//close for i ...
   if(cntr == consecBars && flat())   {//min. consec dn bars and flat position...
      SL=Bid-sl*Point;
      tp = Ask+TP*Point;
      OrderSend(Symbol(),OP_BUY, lots, Ask, 3, SL, tp, "", magic, 0, Blue);
   }//close if ctr of down bars ...

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