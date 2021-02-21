//+------------------------------------------------------------------+
//|                                      AZ_EA_eFMSWBBO_FIRMXMMF.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#define MAGICMA  20050610

extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 3;
//extern double MovingPeriod       = 12;
//extern double MovingShift        = 6;
extern double BandsDeviations    = 2.0;
extern int    BandsPeriod        = 20;
extern double ThldDecimal        = 1.0;
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
   double ma, S1;
   int TF1 = Period();
   int    res;
//---- go trading only for first tiks of new bar
//   if(Volume[0]>1) return;
//---- get Moving Average 
   //ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   S1   =   iCustom(NULL, TF1, "Aharon_FMSlopeWBBOrdered", BandsDeviations, BandsPeriod, ThldDecimal, 0, 0);
                                                           /*Aharon_FMSlopeWBBOrdered Parameters:
                                                             double BandsDeviations=2.0;
                                                             int    BandsPeriod=20;
                                                             double ThldDecimal = 1.0;
                                                           */
   
   //S2   =   iCustom(NULL, TF1, "Aharon_FIRMXMMF", 
     //                TF1, 20, 21, 4,   3, 0, 2,     3, 0, 2,       //parameters as listed below
       //              3, 0);
                     //Mode =3 is square wave signal, shift=o is no shifting of indicator 
                                                           /*int    TF1 = 0;       
                                                             int    Period1 = 20;
                                                             int    Taps1   = 21;     //must be odd number
                                                             int    Window1   = 4;
                                                             int    MA1Period = 2;
                                                             int    MA1shift = 0;
                                                             int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                             int    MA2Period = 2;
                                                             int    MA2shift = 0;
                                                             int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
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
   double ma, S2;
   int TF1 = Period();
//---- go trading only for first tiks of new bar
//   if(Volume[0]>1) return;
//---- get Moving Average 
   //ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   
   //S1   =   iCustom(NULL, TF1, "Aharon_FMSlopeWBBOrdered", BandsDeviations, BandsPeriod, ThldDecimal, 0, 0);
     //                                                      /*Aharon_FMSlopeWBBOrdered Parameters:
       //                                                      double BandsDeviations=2.0;
         //                                                    int    BandsPeriod=20;
           //                                                  double ThldDecimal = 1.0;
             //                                              */
   
   S2   =   iCustom(NULL, TF1, "Aharon_FIRMXMMF", 
                     TF1, 20, 21, 4,   2, 0, 2,     2, 0, 2,       //parameters as listed below
                     3, 0);
                     //Mode =3 is square wave signal, shift=o is no shifting of indicator 
                                                           /*int    TF1 = 0;       
                                                             int    Period1 = 20;
                                                             int    Taps1   = 21;     //must be odd number
                                                             int    Window1   = 4;
                                                             int    MA1Period = 2;
                                                             int    MA1shift = 0;
                                                             int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                             int    MA2Period = 2;
                                                             int    MA2shift = 0;
                                                             int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                           */
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)
        {
         if(S2 == -1.0) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(S2 == 1.0) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
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