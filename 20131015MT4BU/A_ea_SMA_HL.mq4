//  A_ea_SMA_HL.mq4

#define MAGICMA  762583

extern double Lots               = 0.1;
extern int    SL                 = 1000;
extern int    TP                 = 1000;

extern int    Len  = 7;
extern int    MaMaLen = 7;
extern int    Shft = 0;

double ma;
   
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
   ma = iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 4, 0);
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
   double signal0;
   int    res;

   // Trading criteria
   /*if(
      iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 1, 0) < 
      iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 3, 0)  &&
       iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 4, 0 != 0)
      ) signal0 = -1.0;
   if(
      iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 0, 0) > 
      iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 2, 0)   &&
      iCustom(NULL, 0, "A_i_SMA_HL",  Len, MaMaLen, Shft, 4, 0 != 0
      ) signal0 = 1.0;*/
      if(ma==1.0) signal0 = 1.0;
   //---- sell conditions
   if(signal0==-1.0)   {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,getSL("s"),getTP("s"),"",MAGICMA,0,Red);      
      return;
   }
   
   //---- buy conditions
   if(signal0==1.0)   {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,getSL("b"),getTP("b"),"",MAGICMA,0,Blue);
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
        { 
         //if(ma==1.0) OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
         break;
        }
        
      if(OrderType()==OP_SELL)
        {
         //if(ma==1.0) OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
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