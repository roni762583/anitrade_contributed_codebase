//+------------------------------------------------------------------+
//|                                               AZ_EA_eFMSWBBO.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#define MAGICMA  20050610

extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 0;

extern int    HB = 1;        //numbers of bars minimum holding for position before close 
extern int    TF1 = 0;
extern int    Period1 = 20;
extern int    Taps1   = 21;  //must be odd number
extern int    Window1   = 4;
extern int    MA1Period = 3;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
extern int    MA2Period = 3;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
extern int    MomLength = 1; //length for momentum
extern int    BBPeriod = 14;
extern int    BBDeviations = 2;
extern int    BBShift = 0;


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
   double lot=Lots;
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
   if(lot<0.1) lot=0.1;
   return(lot);
  }


//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double S1;
   int    res;
//---- go trading only for first tiks of new bar
//   if(Volume[0]>1) return;
//---- get Moving Average 
   S1   =   iCustom(NULL, 0, "Aharon_eFMMMFMWBB_O", TF1, Period1, Taps1, Window1, MA1Period, MA1shift, MA1method, MA2Period, 
                 MA2shift, MA2method, MomLength, BBPeriod, BBDeviations, BBShift,
                 0, 0);  //current bar 
                                                           /* Parameters
                                                           //Initial values correspond to tested values
                                                             extern int    TF1 = 0;
                                                             extern int    Period1 = 20;
                                                             extern int    Taps1   = 21;  //must be odd number
                                                             extern int    Window1   = 4;
                                                             extern int    MA1Period = 3;
                                                             extern int    MA1shift = 0;
                                                             extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                             extern int    MA2Period = 3;
                                                             extern int    MA2shift = 0;
                                                             extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                             extern int    MomLength = 1; //length for momentum
                                                             extern int    BBPeriod = 14;
                                                             extern int    BBDeviations = 2;
                                                             extern int    BBShift = 0;
                                                           */

   
   
   
//---- sell conditions
   if(S1 == -1.0)               //(Open[1]>ma && Close[1]<ma)  
     {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
      return;
     }
//---- buy conditions
   if(S1 == 1.0)      //   if(Open[1]<ma && Close[1]>ma)  
     {
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
   double S1;

//---- go trading only for first tiks of new bar
 //  if(Volume[0]>1) return;  //only allow close on open of next bar to prevent exitingn on temp. retreat of ind.

//---- get signal
   S1   =   iCustom(NULL, 0, "Aharon_eFMMMFMWBB_O", TF1, Period1, Taps1, Window1, MA1Period, MA1shift, MA1method, MA2Period, 
                 MA2shift, MA2method, MomLength, BBPeriod, BBDeviations, BBShift,
                 0, 0);  //see above for details on params.
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
        {
         if(S1 == 0.0 && Time[0]-OrderOpenTime() > Period()*60*HB ) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(S1 == 0.0 && Time[0]-OrderOpenTime() > Period()*60*HB ) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
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
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
  }
//+------------------------------------------------------------------+