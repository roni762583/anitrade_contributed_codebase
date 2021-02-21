//Aha_EA_Aharon_eMAHLC.mq4

#define MAGICMA  762583

extern double Lots               = 0.1;
extern int    SL                 = 1000;
extern int    TP                 = 1000;
extern int    maxTime            = 3600000;
extern int    MAlen              = 70;
double s0;


//+------------------------------------------------------------------+
//| init() function                                                  |
//+------------------------------------------------------------------+
void init()   {

}


//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void start()  {
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   
   s0   = iCustom(NULL, 0, "Aharon_eMAHLC",  MAlen, 0, 0);
      
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
}


//+------------------------------------------------------------------+
//| CalculateCurrentOrders()                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)   {
   int buys=0,sells=0;

   for(int i=0;i<OrdersTotal();i++)     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)   {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
      }
   }

   if(buys>0) return(buys);
   else       return(-sells);
}


//+------------------------------------------------------------------+
//| CheckForOpen()                                                   |
//+------------------------------------------------------------------+
void CheckForOpen()   {

   int    res;
   
   //---- go trading only for first tiks of new bar
   //   if(Volume[0]>1) return;

   //---- sell conditions
   if(s0==-1.0)   {
      res=OrderSend(Symbol(),OP_SELL,Lots, Bid,3,getSL("s"),getTP("s"),"",MAGICMA,0,Red);      
      return;
   }
   
   //---- buy conditions
   if(s0==1.0)   {
      res=OrderSend(Symbol(),OP_BUY,Lots, Ask,3,getSL("b"),getTP("b"),"",MAGICMA,0,Blue);
      return;
   }
}


//+------------------------------------------------------------------+
//| CheckForClose()                                                  |
//+------------------------------------------------------------------+
void CheckForClose()  {

   //---- go trading only for first tiks of new bar
   //  if(Volume[0]>1) return;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      if(OrderType()==OP_BUY)
        {//if order is old by max min. 
         if( (TimeCurrent()-OrderOpenTime()> maxTime)   ||  s0 == -1.0  ) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
        
      if(OrderType()==OP_SELL)
        {
         if(  (TimeCurrent()-OrderOpenTime()> maxTime)  ||   s0 == 1.0  ) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
         break;
        }
     }

   return;
}


double getSL(string type)   {
   double sl;
   if(type == "b" || type == "B") {//sl for buy order 
      sl = Ask - SL*Point;
   }
   if(type == "s" || type == "S") {//sl for sell order 
      sl = Bid + SL*Point;
   }
   return(sl);
}


double getTP(string type)   {
   double tp;
   if(type == "b" || type == "B") {//tp for buy order 
      tp = Ask + TP*Point;
   }
   if(type == "s" || type == "S") {//tp for sell order 
      tp = Bid - TP*Point;
   }
   return(tp);
}