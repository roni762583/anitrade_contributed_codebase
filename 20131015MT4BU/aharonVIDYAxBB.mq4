//+------------------------------------------------------------------+
//|                                               aharonVIDYAxBB.mq4 |
//|                      Copyright © 2013,     aharon Software Corp. |
//|                                       http://www.google.com      |
//+------------------------------------------------------------------+
#define MAGICMA  20130405

extern double Lots               = 1.00;
extern bool   useMM              = false;
extern double MaximumRisk        = 0.02;
extern double DecreaseFactor     = 0.0;
extern double minPenetration     = 0.30;
extern int    VIDYAsPeriod       = 7;
extern int    BBPeriod           = 11;
extern int    BBDeviation        = 2;
extern int    BBShift            = 0;

static double ubb                = 0.0;
static double lbb                = 0.0;
static double ma                 = 0.0;

       double vma[60]; //to hold VIDYA values for bbOnArray
       
       int    i;



int init()  {
//   ArrayInitialize(vma, 0.777);

   return(0);
}



void start()   {
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   
   for(i=60; i>0; i--)   {                        //copy VIDYA data into local array for iBandsOnArray()
      ma  = iCustom(Symbol(), 0, "VIDYA", 3, 0, i);        //VIDYA a.k.a Variable moving avg.
      vma[i] = ma;                                         //array to hold vma data
   }//close for(i
   //ma  = iCustom(Symbol(), 0, "VIDYA", 3, 0, 0);
   ubb = iBandsOnArray(vma, 0, BBPeriod, BBDeviation, BBShift, MODE_UPPER, 0);
   lbb = iBandsOnArray(vma, 0, BBPeriod, BBDeviation, BBShift, MODE_LOWER, 0);
   
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
   int    res;                                             //result of trade
                                                           //---- sell conditions
   if(ma+minPenetration<lbb)    { //VIDYA below lower BB of VIDYA
      Print("SELL condition found: ma=",ma,"   lbb=",lbb);
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
      return;
   }//close if(Open[....
   
                                                           //---- buy conditions
   if(ma-minPenetration>ubb)   {
      Print("BUY condition found: ma=",ma,"   ubb=",ubb);
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
      return;
   }//close if(Open[...
}//close CheckForOpen()



void CheckForClose()   {
   
   //---- go trading only for first ticks of new bar
   //if(Volume[0]>1) return;
   //---- get Moving Average 

   for(i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //---- check order type 
      if(OrderType()==OP_BUY)  {  //if long...
         if(ma-minPenetration<ubb) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
      }//close if(OrderType()...)
      if(OrderType()==OP_SELL)  { //if short...
         if(ma-minPenetration>lbb) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
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