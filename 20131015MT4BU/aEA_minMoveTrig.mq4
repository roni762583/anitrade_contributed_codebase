//                                         aEA_minMoveTrig.mq4  |
//|                                                   
//|                                                
//|                                              
//+------------------------------------------------------------------+

#property copyright "ANITANI"
#property link      "www.anitani.com"

extern int TakeProfit = 155; // 
extern int StopLoss = 2000; //
extern int indexLast = 1;
extern int indexFirst = 2;
extern int PointsThreshold = 50;//on a 5 decimal broker
extern bool TrendTrueCountertrendFalse = true;
extern int magicNo   = 762583;
extern double lot = 1;

int ticket;


int start()  {

  if( MathAbs(Close[indexLast] - Close[indexFirst])/Point >= PointsThreshold )   {//if threshold move...
     if(Close[indexLast]>Close[indexFirst])   {                                               //if UP trend...
        if(TrendTrueCountertrendFalse && isFlat())  OpenLong(lot);                       //if trend BUY
        if(!TrendTrueCountertrendFalse && isFlat()) OpenShort(lot);                      //if counter trend, SHORT 
     }
     if(Close[indexLast]<Close[indexFirst])   {                                               //if DOWN trend...
        if(TrendTrueCountertrendFalse && isFlat())  OpenShort(lot);                      //if trend SHORT
        if(!TrendTrueCountertrendFalse && isFlat()) OpenLong(lot);                       //if counter trend, BUY 
     }
  }
     
  return(0);
}


int OpenLong(double volume=0.1)
{
  int slippage=10;
  string comment="20/200 expert (Long)";
  color arrow_color=Red;
  int magic=magicNo;

  ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,Ask-StopLoss*Point,
                      Ask+TakeProfit*Point,comment,magic,0,arrow_color);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    {
      Print("Buy order opened : ",OrderOpenPrice());
      return(0);
    }
  }
  else
  {
    Print("Error opening Buy order : ",GetLastError());
    return(-1);
  }
}

int OpenShort(double volume=0.1)
{
  int slippage=10;
  string comment="20/200 expert (Short)";
  color arrow_color=Red;
  int magic=magicNo;

  ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,Bid+StopLoss*Point,
                      Bid-TakeProfit*Point,comment,magic,0,arrow_color);
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
        Print("Sell order opened : ",OrderOpenPrice());
        return(0);
      }
  }
  else
  {
    Print("Error opening Sell order : ",GetLastError());
    return(-1);
  }
}

bool isFlat()  { //will return true if no open orders from this EA magic - ignores other orders in system, ignores pending and historical orders 
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            totalOrders++;
         }//close if(OrderSelect...
   }//close for loop
   //Print(" from isFlat(): totalOrders = ", totalOrders);
   if(totalOrders==0) return(true);
   return(false);
}//close isFlat()


int init()
{
  return(0);
}

int deinit()
{
  return(0);
}

