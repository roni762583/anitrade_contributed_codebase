//+------------------------------------------------------------------+
//|                                                     A_simple.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

extern double lots  = 0.01;
extern int tp = 10;
extern int sl = 25;
extern double minVel = 2.0;  //minimum velocity pips/per sec.


int MAGICMA = 732, counter = 0;
double b1, b2, b3, b4;
double t1, t2, t3, t4;
double v = 0.0, av = 0.0;
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
int start()
  {
//----
   counter = counter + 1;
   t4 = t3;
   t3 = t2;
   t2 = t1;
   t1 = GetTickCount();
   
   b4 = b3;
   b3 = b2;
   b2 = b1;
   b1 = Bid;
//   if(position()) check4close();
//   else check4open();
   //check4open();
   if(counter>4)   {
      v = ((b1-b4)*MathPow(10,Digits))/(MathMax((t1-t4),1)/1000);
      av = av + v;
   }
   Comment("Vel. Pips/Sec.  "+v+"\n" + 
           "Accum. Vel. "+av);
//----
   return(0);
  }
//+------------------------------------------------------------------+
bool position()   {
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        return(false);
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol() || OrderCloseTime()!= 0 || OrderType() > 1) continue; //only catch open orders for this symbol and strategy
      return(true);
   }
}

void check4close()   {
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol() || OrderCloseTime()!= 0 || OrderType() > 1) continue; //only catch open orders for 
      
      if(OrderType()==0 && Bid>=OrderOpenPrice()+tp*Point)   //if buy and reached target
         OrderClose(OrderTicket(), OrderLots(), Bid, 3);
      if(OrderType()==1 && Ask<=OrderOpenPrice()-tp*Point)   //if sell and reached target
         OrderClose(OrderTicket(), OrderLots(), Ask, 3); 
         
      if(OrderType()==0 && Bid<=OrderOpenPrice()-sl*Point)   //if buy and reached sl
         OrderClose(OrderTicket(), OrderLots(), Bid, 3);
      if(OrderType()==1 && Ask>=OrderOpenPrice()+sl*Point)   //if sell and reached sl
         OrderClose(OrderTicket(), OrderLots(), Bid, 3);
   }
}

void check4open()   {
   //if(Ask>MathMax(High[1],High[2]) )  //if price exceeds last 2 bars' high, then BUY
   if( ((b1-b4)*MathPow(10,Digits))/(MathMax((t1-t4),1)/1000) >minVel)     //b1<b2 && b2<b3 && b3<b4
      OrderSend(Symbol(), OP_BUY, lots, Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
      
   //if(Bid<MathMin(Low[1],Low[2]) )  //if price unvershoots last 2 bars' lows, then SELL
   if( -1*((b1-b4)*MathPow(10,Digits))/(MathMax((t1-t4),1)/1000) >minVel)  //b1>b2 && b2>b3 && b3>b4
      OrderSend(Symbol(), OP_SELL, lots, Bid, 3, 0, 0, "", MAGICMA, 0, Red);
}