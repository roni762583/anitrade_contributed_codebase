//+------------------------------------------------------------------+
//|                                                      AGA_HIW.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#define MAGICMA  02762583

extern double Lots               = 0.1;
extern double MaximumRisk        = 0.02; //percentage of margin for lot calculation OrderMagicNumber
extern double DecreaseFactor     = 0;    //used in templete EA to reduce lots after losses sustained...see code below...replace w/ Kelly
extern double TP                 = 12;    //take profit...this should be based on ATR, or on expected support/resistance level
//extern int    SLtype             = 1;    //this selects whether to use SAR (1), or fixed Trailing Stop (2)
//extern double tSL                = 10;   //trailing stop distance
//extern double SARstep            = 0.1; //SAR Param
//extern double SARmaximum         = 0.5;  //SAR Param
extern int    m1                 = 3;    //period of 1st average
extern int    m2                 = 6;    //period of 2nd 
extern int    m3                 = 18;   // of 3rd

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)     {
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
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   if(Lots == 0) lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
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
   double ma1, ma2, ubb, lbb, eM, effso, fmmx0, fmmx1;
   int    res, spread;
//---- go trading only for first tiks of new bar
//  if(Volume[0]>1) return;
//---- get Moving Average 
   
   ma1=iMA(NULL,0,m1,0,MODE_EMA,PRICE_CLOSE,0);
   ma2=iMA(NULL, 0, m2,0,MODE_EMA,PRICE_CLOSE,0);
   ma3=iMA(NULL, 0, m3,0,MODE_EMA,PRICE_CLOSE,0);
   
   
   st = ST;
   lt = LT;
   if(ma1>ma2) ST = 1;
      else if (ma1<ma2) ST = -1;
   if(st != ST) st = 0; //there was a change toggle
   
   if(ma2>ma3) LT = 1;
      else if (ma2<ma3) LT = -1;
   if(lt != LT) lt = 0;//there was a change toggle
   
   if(ma1>ma2 && ma2>ma3 && st==0 && lt !=0)  {  //Continuation upwards all 3 ma's aligned upwards and there was toggle in short-term, but no toggle in long-term
      //do what is to be done in continuation
   }
   
   dn cntntn
   crsovr up
   crsovr dn
   /////////////////////   continue here   //////////////////////
   
   
//---- sell conditions
   if( effso == -1.0 && eM == 1.0 && fmmx0 == -1.0) //Open[1]>ma && Close[1]<ma)   && ma2<0 && ma0<ma1 && ma1<ma2
     {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,
      (Bid + Point*(tSL+spread)), //sl
      (Bid - Point*TP),          //tp
      "",MAGICMA,0,Red);
      
      if(res>0) Print("Sell Order:  sl = ", (Bid + Point*(tSL+spread)), "  tp = ", (Bid - Point*(TP+spread)) );
      
      return;
     }
     
//---- buy conditions
   if( effso == 1.0 && eM == 1.0 && fmmx0 == 1.0) //Open[1]<ma && Close[1]>ma)   && ma2>0 && ma0>ma1 && ma1>ma2
     {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,
      (Ask - Point*(spread+tSL)), //sl
      (Ask + Point*TP),          //tp
      "",MAGICMA,0,Blue);
      
      if(res>0) Print("Buy Order:  sl = ", (Ask - Point*(spread+tSL)), "  tp = ", (Ask + Point*TP) );
      
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()  {
   double ma0,ma1,ma2, lz, fmmx0, fmmx1;
//---- go trading only for first tiks of new bar
//   if(Volume[0]>1) return;
//---- get Moving Average 
   /*
   ma0 = iCustom(NULL, 0, "Aharon_FSBBLHLL",
                BandsDeviations, BandsPeriod,
                0, 0);                          //iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   
   ma1 = iCustom(NULL, 0, "Aharon_FSBBLHLL",
                BandsDeviations, BandsPeriod,
                0, 1);             
   ma2 = iCustom(NULL, 0, "Aharon_FSBBLHLL",
                BandsDeviations, BandsPeriod,
                0, 2);
   
   lz  = iCustom(NULL, 0, "Aharon_FSBBLHLL",
                BandsDeviations, BandsPeriod,
                3, 2);
   */           
   fmmx0 = iCustom(NULL, 0, "Aharon_eFIRMXMMF",
                  0, 20, 21, 4,   m1, 0, 2,     m2, 0, 2,
                  0, 0); //-1, 1
                  
   fmmx1 = iCustom(NULL, 0, "Aharon_eFIRMXMMF",
                  0, 20, 21, 4,   m1, 0, 2,     m2, 0, 2,
                  0, 1); //-1, 1
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      
      //Close BUY Order 
      if(OrderType()==OP_BUY)  {
         if(fmmx0 ==-1.0  && fmmx1 == 1.0) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);          //Open[1]>ma && Close[1]<ma) 
         break;
      }
        
      //Close SELL Order   
      if(OrderType()==OP_SELL)   {
         if(fmmx0 == 1.0 && fmmx1 == -1.0) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
      }
     }
//----
}

//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()  {
                        //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
                        //---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else       {
                                          AdjustSL(SLtype);
                                          CheckForClose();
   }
}
//+------------------------------------------------------------------+


int AdjustSL(int SLtype)   {
   bool answ;
   double sar;
   int i;
   switch(SLtype)   {
   
      case 1:                                              //This is SAR Stop Loss
         if(Volume[0]>2) return;                           //only adjust SL on new bar, 2 instead of 1 in case it misses the first tick
         sar = iSAR(NULL, 0, SARstep, SARmaximum, 0);
         for(i=0;i<OrdersTotal();i++)  {               //loop over orders 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;  //if OrderSelect function does not succeed, break;
            if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;  //if not correct magic number, or security, next order
           
            //Modify SL for BUY Order
            if(OrderType()==OP_BUY)   {                    //if BUY type...
               if(sar<Open[0] && sar>OrderStopLoss())  {   //if SAR below bar (it may not be formed IAW order,) and sar > than current order SL, set new stoploss value
                  OrderModify(OrderTicket(), OrderOpenPrice(), sar, OrderTakeProfit(), 0, Gold);  //modify order using new SAR SL value
               } 
            }
            
            //Modify SL for SELL Order
            if(OrderType()==OP_SELL)   {
               if(sar>Open[0] && sar<OrderStopLoss())  {
                  OrderModify(OrderTicket(), OrderOpenPrice(), sar, OrderTakeProfit(), 0, Gold);
               }
            }
         } // close orders' for loop
      
      case 2:                                              //This is for fixed Trailing Stop 
         // In this case of a trailing stop, we want to check for high water mark at every tick
         for(i=0;i<OrdersTotal();i++)  {               //loop over orders 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;  //if OrderSelect function does not succeed, break;
            if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;  //if not correct magic number, or security, next order
           
            //Modify SL for BUY Order
            if(OrderType()==OP_BUY)   {                    //if BUY type...
               if(Bid-OrderStopLoss() > tSL*Point)   {
                  Alert("Attempt to modify Trailing Stop Loss for BUY Ticket " + OrderTicket() + " ...");
                  answ = OrderModify(OrderTicket(), OrderOpenPrice(), (Bid-(Point*tSL)), OrderTakeProfit(), 0, Gold);
                  if(answ) Alert("BUY Order " + OrderTicket() + " SL has been modified to " + OrderStopLoss());
               }
            }
         
            //Modify SL for SELL Order
            if(OrderType()==OP_SELL)   {
               if(Ask-OrderStopLoss() > tSL*Point)   {
                  Alert("Attempt to modify Trailing Stop Loss for SELL Ticket " + OrderTicket() + " ...");
                  answ = OrderModify(OrderTicket(), OrderOpenPrice(), (Ask+(Point*tSL)), OrderTakeProfit(), 0, Gold);
                  if(answ) Alert("SELL Order " + OrderTicket() + " SL has been modified to " + OrderStopLoss());
               }
            }
         } //close orders' for loop
         
      default:
         Alert("Wrong value selected for SLtype parameter," + "\n" +
               "Please enter 1 for SAR, or 2 for a fixed Trailing Stop" );
   } //close switch statement
   return(0);
}//close AdjustSL() function