//                                         aEA_monkey.mq4  |
//|                                                    1H   EUR/USD  |
//|                                                
//|                                              
//+------------------------------------------------------------------+

#property copyright "ANITANI"
#property link      "www.anitani.com"

extern int TakeProfit = 155; // 
extern int StopLoss = 2000; //
//extern double thrshld = 0.0007;
extern double lot = 1;

int ticket;


int start()  {
  MathSrand(TimeLocal());

  double s1 = MathRand();   //returns a pseudorandom integer within the range of 0 to 32767
  MathSrand(s1);
  s1 = MathRand();
  if(OrdersTotal()<1)   {
       if(s1<16383.5)   OpenLong(lot);
       if(s1>16383.5)   OpenShort(lot);
  }
   
  return(0);
}




int OpenLong(double volume=0.1)
{
  int slippage=10;
  string comment="20/200 expert (Long)";
  color arrow_color=Red;
  int magic=0;

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
  int magic=0;

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

int init()
{
  return(0);
}

int deinit()
{
  return(0);
}

