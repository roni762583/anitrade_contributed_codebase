//+------------------------------------------------------------------+
//|                                                   A_ea_MAxMA.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//despite the name this aligns trade direction to BB7BASlp_Acc ind 
#property copyright "Aharon"
#property link      "http://www.anitani.net"

extern double MaxZscore = 2.0;
extern double MinZscore = -2.0;

extern double MaxFlattenZscore = 0.1;
extern double MinFlattenZscore = -0.1;

extern int    ma_period = 20;

static bool main = true;  //this is main switch flag to hault operations
static int  MAGICMA = 762583;

double ind =  0.0,
       ind2 = 0.0;
////////////////////////////
int init()  {
   return(0);
}


/////////////////////////////
int start()  {
   int res = 0;
   if(main == false)  {
      Alert("Error - stopped working");
      Comment("Error - stopped working");
      return;
   }

//   ind  = iCustom(NULL, 0, "A_i_BB7BASlp_Acc", 2.0, 20, 6, 0);
   ind2 = iCustom(NULL, 0, "Aharon_BB_on_7barslope_Zscore", ma_period, 1, 0);
  
   if(tradedirection()==2) main = false;
   
   if(tradedirection()==1 && ind2>MaxZscore) return;     //case where trade and ind agree
   if(tradedirection()==-1 && ind<MinZscore) return;
   
   if(tradedirection()==1  && ind2<MaxFlattenZscore) flatten();  //case where trade and ind disagree - flatten
   if(tradedirection()==-1 && ind2>MinFlattenZscore) flatten();  //flatten
   
   if(tradedirection()==0 && ind2>MaxZscore)              //buy
      res=OrderSend(Symbol(),OP_BUY, 0.1,Ask,3,0,0,"",MAGICMA,0,Blue);
   if(tradedirection()==0 && ind2<MinZscore)              //sell
      res=OrderSend(Symbol(),OP_SELL, 0.1,Bid,3,0,0,"",MAGICMA,0,Red);
   
/* 
   if(tradedirection()==1 && ind==0.01) return;     //case where trade and ind agree
   if(tradedirection()==-1 && ind==-0.01) return;
   
   if(tradedirection()==1 && ind==-0.01) flatten();  //case where trade and ind disagree - flatten
   if(tradedirection()==-1 && ind==0.01) flatten();  //flatten
   
   if(tradedirection()==0 && ind==0.01)              //buy;
      res=OrderSend(Symbol(),OP_BUY, 0.1,Ask,3,0,0,"",MAGICMA,0,Blue);
   if(tradedirection()==0 && ind==-0.01)             //sell
      res=OrderSend(Symbol(),OP_SELL, 0.1,Bid,3,0,0,"",MAGICMA,0,Red);
*/      

   return(0);
}


/////////////////////
int tradedirection()  {  //returns direction of position for symbol: 1=long, -1=short, 0=no trades, 2=both long and short, or more than one position
   int cnt, total, bcnt, scnt; 
   total=OrdersTotal();
   if (total==0) return(0);
   bcnt=0;
   scnt=0;
   for(cnt=0;cnt<total;cnt++)   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderSymbol()==Symbol() && OrderType()==OP_BUY  && OrderMagicNumber()== MAGICMA)  bcnt++;
     if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()== MAGICMA) scnt++;     
   }
   if(bcnt>0 && scnt>0) return(2);//checks if both long and short 
   if(bcnt>1 || scnt>1) return(2);//checks if more than one position in direction
   if(bcnt==1 && scnt==0) return(1);
   if(bcnt==0 && scnt==1) return(-1);
   if(bcnt==0 && scnt==0) return(0);
}


/////////////////
void flatten()   {
   int cnt, total;
   total=OrdersTotal();
   if (total==0) return(0);  //if this returns there is some error
   for(cnt=0;cnt<total;cnt++)   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderSymbol()==Symbol() && OrderType()==OP_BUY  && OrderMagicNumber()== MAGICMA)  OrderClose(OrderTicket(),OrderLots(),Bid,3,White);//close long 
     if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()== MAGICMA)  OrderClose(OrderTicket(),OrderLots(),Ask,3,White);//close short     
   }
}


///////////////////////
int deinit()  {
   return(0);
}