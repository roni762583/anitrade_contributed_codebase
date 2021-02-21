//|                   20/200 expert.mq4 --> Gid_Secrete5min_mod1.mq4 |
//|                                                    1H   EUR/USD  |
//|                                                    Smirnov Pavel |
//|                                                 www.autoforex.ru |
//+------------------------------------------------------------------+

#property copyright "MOD1 MOD1"
#property link      "www.autoforex.ru"
//settings optimized for GBPUSD on 11/'12 three months history 
extern int TakeProfit = 100; // 
extern int StopLoss = 2000; //
extern int TradeTime=11;
extern int t1=0;
extern int t2=2;
extern int delta=60;
extern double lot = 0.1;
extern bool useTime = true;
int ticket;
bool cantrade=true;


int init()  {  return(0);  }


int start()   {
   
   if((TimeHour(TimeCurrent())>TradeTime) && useTime) cantrade=true;
   if(!useTime) cantrade=true;
   
   if(OrdersTotal()<1)   {
      if((TimeHour(TimeCurrent())==TradeTime)&&(cantrade)&& useTime)   {
         if ((Open[t1]-Open[t2])>delta*Point)   {
            if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0 || GetLastError()==134)   {
               Print("Not enough money");
               return(0);
            }//close if(AccountFreeMar...
            OpenShort(lot);
            cantrade=false;
            return(0);
         }//close if ((Open[t1..
         if((Open[t2]-Open[t1])>delta*Point) {
            if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0 || GetLastError()==134)   {
               Print("Not enough money");
               return(0);
            }//close if(AccountFree...
            OpenLong(lot);
            cantrade=false;
            return(0);
         }//close if((Open[t2]....
      }//close if((TimeHour(Tim....
      /////////////////////////////////////////////////////////////////////////////
      if(cantrade && !useTime)   {
         if ((Open[t1]-Open[t2])>delta*Point)   {
            if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0 || GetLastError()==134)   {
               Print("Not enough money");
               return(0);
            }//close if(AccountFreeMar...
            OpenShort(lot);
            cantrade=false;
            return(0);
         }//close if ((Open[t1..
         if((Open[t2]-Open[t1])>delta*Point) {
            if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0 || GetLastError()==134)   {
               Print("Not enough money");
               return(0);
            }//close if(AccountFree...
            OpenLong(lot);
            cantrade=false;
            return(0);
         }//close if((Open[t2]....
      }//close if((TimeHour(Tim....
      /////////////////////////////////////////////////////////////////////////////
   }//close if(OrdersTo...
   
   return(0);
}//close start()


int OpenLong(double volume=0.1)   {
   int slippage=10;
   string comment="20/200 expert (Long)";
   color arrow_color=Red;
   int magic=0;
   ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,Ask-StopLoss*Point,
                      Ask+TakeProfit*Point,comment,magic,0,arrow_color);
   if(ticket>0)   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))   {
         Print("Buy order opened : ",OrderOpenPrice());
         return(0);
      }
   }
   else   {
      Print("Error opening Buy order : ",GetLastError());
      return(-1);
   }
}


int OpenShort(double volume=0.1)   {
   int slippage=10;
   string comment="20/200 expert (Short)";
   color arrow_color=Red;
   int magic=0;
   ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,Bid+StopLoss*Point,
                      Bid-TakeProfit*Point,comment,magic,0,arrow_color);
   if(ticket>0)   {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))   {
        Print("Sell order opened : ",OrderOpenPrice());
        return(0);
     }
   }
   else   {
      Print("Error opening Sell order : ",GetLastError());
      return(-1);
   }
}


int deinit()   {
  return(0);
}