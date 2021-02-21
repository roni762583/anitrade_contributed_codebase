//  A_ea_P_S_R.mq4

#define MAGICMA  762583

extern double Lots               = 0.1;
int    res;
double sig, r1, s1, p;
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
   sig = iCustom(NULL, 0, "A_i_try_P_S_R", 7, 0);
   r1  = iCustom(NULL, 0, "A_i_try_P_S_R", 1, 0);
   s1  = iCustom(NULL, 0, "A_i_try_P_S_R", 4, 0);
   p   = iCustom(NULL, 0, "A_i_try_P_S_R", 0, 0);
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
   //---- sell conditions
   if(sig == -1.0)   {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3, r1, s1, "", MAGICMA, 0, Red);      
      return;
   }
   
   //---- buy conditions
   if(sig ==  1.0)   {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3, s1, r1,"",MAGICMA,0,Blue);
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
/*
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
*/