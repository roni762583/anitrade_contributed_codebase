//+------------------------------------------------------------------+
//|                                             AZ_WWJ_ASI3.5_EA.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#define MAGICMA  672583

//extern double Lots               = 0.1;

//extern int barsback  =  180;

double ind;


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
double LotsOptimized()
  {
   double lot=0.1;
   /*
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
   if(lot<0.1) lot=0.1;*/
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ma, lbb;
   int    res;
//---- go trading only for first tiks of new bar
  // if(Volume[0]>1) return;
   
   //lbb=iBands(NULL, 0, 20, 2, 0, PRICE_LOW, MODE_LOWER, 0) ;
   

//---- sell conditions
   if(ind==-1.0)   {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
      return;
   }
   
//---- buy conditions
   if(ind==1.0)    {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
      return;
   }
//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{
 //  double ma;
//---- go trading only for first tiks of new bar
  // if(Volume[0]>1) return;
//---- get Moving Average 
   
//----
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
      {
         if(ind==0.0) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
      }
        
      if(OrderType()==OP_SELL)
      {
         if(ind==0.0) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
      }       
   }
//----
}


//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()
{
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   //slp=iCustom(NULL, 15, "Aharon_7_Bar_Avg_Slope_Pips_per_Min", 1, 0);
   
   ind = iCustom(NULL, 0, "A_i_WWJ_ASI35", 0, 0);
   
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
}
//+------------------------------------------------------------------+//+------------------------------------------------------------------+