#define MAGICMA  762583

extern double Lots       = 0.01;
extern double increment  = 20;  //pips
extern int TP    = 20; //in pips
extern int SL    = 60; //in pips

extern double sessionprofittarget        = 1000.0;
extern double maxdispare                 = 1000.0; //max amount in unrealized p/l before closing all orders 

int    res, bo, so, mode, lastticket; //mode 1 is trend,    mode -1 is swing
double lastprice, bpl, spl;
bool SellOK=true, BuyOK=true;


void init()   {
   lastprice = Open[0];
}


void start()  {
   if(Bars<100 || IsTradeAllowed()==false) return;   
   calcPL();                    //tallies buys, sells, and respective group p/l
//   interpretPL();               //interpret p/l calculated in calcPL()-limit new orders in opposite trending mkt
   CheckForClose();             //for aggregate order situations
   CheckForOpen();
   return;
}


void CheckForOpen()   {

      if(Ask > (lastprice + increment*Point) )   {                                   //if price moved up and Buys are OK'd
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3, 0, 0,"",MAGICMA,0,Blue);  //then Buy
         if(res>0)   {
            OrderSelect(res, SELECT_BY_TICKET);
            lastprice = OrderOpenPrice();  //if went through, set lastprice to order price 
            lastticket = res; //set last ticket to last open order of current mode 
         }
      }   
      
      //sell criteria
      if(Bid < (lastprice - increment*Point) && SellOK)   {                                  //if price moved down and Sells are OK'd
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3, 0,0,"",MAGICMA, 0,Red);  //then Sell
         if(res>0)   {
            OrderSelect(res, SELECT_BY_TICKET);
            lastprice = OrderOpenPrice();      //if went through, set lastprice to order price 
            lastticket = res; //set last ticket to last open order of current mode 
         }
      }
      
   return;
}


void CheckForClose()  {
   double TP, SL;
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol() || OrderCloseTime()!= 0 || OrderType() > 1) continue; //only catch open orders for this symbol and strategy
      
         TP = TP*Point;
         SL = SL*Point;
        
      //close profitable buy
      if(OrderType()==0 &&                                       //if buy type
         OrderOpenPrice() <= Bid-TP)                             //and as profitable as TP
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Yellow);  //then close 
      
      //close profitable sell
      if(OrderType()==1 &&                                       //if sell type
         OrderOpenPrice() >= Ask+TP)                             //and as profitable as TP
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);  //then close 
           
      //close lossing buy
      if(OrderType()==0 &&                                       //if buy type
         Bid < OrderOpenPrice()-SL )   {                          //and as profitable as TP
            //togglemode();
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Yellow);  //then close 
      }
      //close lossing sell
      if(OrderType()==1 &&                                       //if sell type
         Ask > OrderOpenPrice()+SL )   {                          //and as profitable as TP
            //togglemode();
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);  //then close 
      }
      
      //close aggregate situations   
      if(MathAbs(AccountBalance()-AccountEquity())>maxdispare) closeall();
      if(MathAbs(bpl+spl)>sessionprofittarget) closeall();
   }
   return;
}


void closeall()  {
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol() || OrderCloseTime()!= 0 || OrderType() > 1) continue; //only catch open orders for this symbol and strategy
      if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,Yellow);  //if buy type
      if(OrderType()==1) OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow);  //if 
   }
}

void calcPL()   {
   bo  = 0;
   so  = 0;
   bpl = 0;
   spl = 0;
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol() || OrderCloseTime()!= 0 || OrderType() > 1) continue;
      //tally
      if(OrderType()==0)   {  //longs
         bo=bo+1;
         bpl=bpl+OrderProfit();
      }
      if(OrderType()==1)   {  //shorts
         so=so+1;
         spl=spl+OrderProfit();
      }
   }
   return;
}


