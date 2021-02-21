//+------------------------------------------------------------------+
//|                    YAZ_enter_multi_exit_parabSAR.mq4      
//YAZ_20130414goodOn1min.mq4       |
//|                      Copyright © 2013,     aharon Software Corp. |
//|                                       http://www.google.com      |
//+------------------------------------------------------------------+
//to enter on multiple indicators exit on parabolic sar

#define MAGICMA  20130412

extern double   Lots               = 0.1;
extern bool     useMM              = false;
extern double   MaximumRisk        = 0.02;
extern double   DecreaseFactor     = 0.0;
extern double   trailPts           = 700.0;
extern double   decreaseTrlFactor  = 0.02;
extern int      AMAn               = 10;
extern int      AMAnmin            = 2;
extern int      AMAnmax            = 5;
extern int      maPeriod           = 3;
extern int      BBperiod           = 20;
extern int      BBdeviation        = 2;
extern int      BBshft             = 0;

static double   exit, 
                lop                = 99999.0, 
                trl,
                thld               = 0.0,
                pbmax, //pull back maximum
                entrySig;
                
static string   lastOrderTimeString;
       int    i;

int init()  {
   return(0);
}

void start()   {
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   
   //Signals used:
   
   //bands on range - must be above ubb (volitility)
    //changed to contrarian 
    entrySig = 0.0 - iCustom(Symbol(),0,"SMA_on_AMA_Diff_wBBwSig", AMAn, AMAnmin, AMAnmax, maPeriod, BBperiod, BBdeviation, BBshft, 3, 0);
   //double s0       = iCustom(Symbol(),0,"SMA_on_AMA_Diff_wBBwSig", AMAn, AMAnmin, AMAnmax, maPeriod, BBperiod, BBdeviation, BBshft, 0, 0);
   //double s1       = iCustom(Symbol(),0,"SMA_on_AMA_Diff_wBBwSig", AMAn, AMAnmin, AMAnmax, maPeriod, BBperiod, BBdeviation, BBshft, 0, 1);
   
//if(entrySig>0.0 || entrySig<0.0 ) Print("entrySig detected");
   //---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
}

int CalculateCurrentOrders(string symbol)  {
   int buys=0,sells=0;
   
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)   {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
      }
   }

   if(buys>0) return(buys);
   else       return(-sells);
}//close function


void CheckForOpen()   {
//Print("hello from checkForOpen sig = ",entrySig);
   int    res;                                             //result of trade
   
   //---- go trading only for first ticks of new bar
   //if(Volume[0]>1) return;
   
   //---- sell conditions
   if(entrySig<0.0 && TimeToStr(Time[0],TIME_MINUTES)!=lastOrderTimeString)    { 
   //Print("sell signal detected");
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
      lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES);//prevent reentering market at same minute as last order 
      return;
   }//close if(Open[....
   
                                                           //---- buy conditions
   if(entrySig>0.0 && TimeToStr(Time[0],TIME_MINUTES)!=lastOrderTimeString)   {
   //Print("buy signal detected");
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
      lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES);
      return;
   }//close if(Open[...
}//close CheckForOpen()


void CheckForClose()   {

   for(i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      bool exit = false; //initialize exit to false
      
      if(lop == 99999.0)  { //at initial state set lop and trl
         lop = OrderProfit(); //initially set lop
         trl = trailPts;
         pbmax = 0.0;
      }
      
      //high water mark
      if(OrderProfit()>lop)   {
         lop=OrderProfit(); //update lop (last OrderProfit) to high water mark
         if(lop>8.0) thld = 0.05 * thld;
         //if(lop>=9.0) exit = true;
      }
      
      thld = trl*MarketInfo(Symbol(),MODE_TICKVALUE)*OrderLots() ;
      
      if(lop-OrderProfit()>pbmax) pbmax = lop-OrderProfit();
      
      if(OrderProfit()<=(lop-thld) ) {
         exit = true;
         Print("OrderProfit=",OrderProfit()," fell below(",lop,"-",thld,"=",lop-thld,") pbmax = ", pbmax  );
      }
                 
      //---- check order type 
      if(OrderType()==OP_BUY)  {  //if long...
         if(exit)  {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,White);//(ubb+lbb)/2
            lop = 99999.0;
            thld = 0.0;
         }
         break;
      }//close if(OrderType()...)
      
      
      if(OrderType()==OP_SELL)  { //if short...
         if(exit)   {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
            lop = 99999.0;
            thld = 0.0;
         }
         break;
      }//close if(OrderType()...
   }//close for(...
}//close function


double LotsOptimized()   {
   double lot = Lots; //0.01
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break

   if(useMM) lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

   if(DecreaseFactor>0)   {
      //---- calcuulate number of losses orders without a break
      for(int i=orders-1;i>=0;i--)   {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;

         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
      }//close for(int i=...
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   }//close if(DecreaseFactor>0)
   if(lot<0.01) lot=0.01;
   return(lot);
}//close function