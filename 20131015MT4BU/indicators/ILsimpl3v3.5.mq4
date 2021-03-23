//ILsimple3v3.5.mq4
//enter on ATR > Thld
//good on EURUSD 1M Thld=0.0012, TP=130 points (on 5digit), SL = 540
//v3 replaces ATR with Open-Close   //ideas for later: try divide by tick vol, compare to Open of a bar ago
//v4 failed - attempt to exit on opposite signal 
//v3.5 will replace entering order w/ TP and SL with monitoring TP SL w/in EA to avoid gunning


#property copyright "Aharon"


extern double   lots            = 0.10;
extern double   Thld            = 0.001;
extern int      TPinPoints      = 320;
extern int      SLinPoints      = 595;


static int      MAGICMA         = 762583199;
static int      myTicket        = -9; //used to keep last open order ticket no. 
static datetime timeOfLastBar;

double          s1, s, es;//jmaCrXXslow, jmaCrXXfast;   


int start()  {
   //Comment("Unreal. P/L " + getPositionOpenPLpts());

     s1      = MathAbs(Close[0]-Open[0]);//iATR(Symbol(), 0, 1, 0);
//synthesize signal
     if(s1>Thld && Open[0]<Close[0])  s =  1.0;     
     if(s1>Thld && Open[0]>Close[0])  s = -1.0;
     es = -9.0;
     if(myPosition()!=-9 && myPosition()!=0 && (getPositionOpenPLpts()>TPinPoints || getPositionOpenPLpts()<0-SLinPoints))
     es = 0.0; //if OrderProfit is greater than set TP or SL, then exit
     
     //for now, just hard code a set TP, later can add an exit strategy!!!!!!!!!!!!!!!!!!!!!
/*
     if(  
          ( (jmaCrXXslow!=1.0 && jmaCrXXfast==-1.0)  && //slow NOT up AND fast down AND
            myPosition()>0 &&                           //i'm short AND
            myPosition()!=-9                            //no error in my position
          )                                             //--close left
          ||                                            // OR
          ( (jmaCrXXslow!=-1.0 && jmaCrXXfast==1.0) &&  //slow NOT down AND fast up AND
            myPosition()<0 &&                           //i'm short AND
            myPosition()!=-9                            //no error in my position
          )                                             //--close right
           //this was good on eurnzd 1h
          //not so good (jmaCrXXslow != myPosition() && myPosition()!=0 && myPosition()!=-9)
       )         s =  0.0;                              //set signal to close position

*/
/*
     if( !(jmaCr47>0.0 && jmaCr714>0.0 && jmaVel17>0.0 && jmaVel57>0.0) ||
         !(jmaCr47<0.0 && jmaCr714<0.0 && jmaVel17<0.0 && jmaVel57<0.0)    )         s =  0.0; //exit         
     if(jmaCr47>0.0 && jmaCr714>0.0 && jmaVel17>0.0 && jmaVel57>0.0 && jmaAcc57>0.0) s =  1.0; //enter long 
     if(jmaCr47<0.0 && jmaCr714<0.0 && jmaVel17<0.0 && jmaVel57<0.0 && jmaAcc57<0.0) s = -1.0; //enter short      
*/



//Buisness
      if(inTrade()) {
         checkForClose(); //if in trade, check for close 
      }//close if()
      else   {
         checkForOpen(); //otherwise check for open
      }//close else 
  // }//close if(isNewBar()...
   
   return(0);
}//close start function


double getPositionOpenPLpts()  { //returns int point of unrealized P/L  - ignore commissions and swaps
   for(int i=0; i<=OrdersTotal(); i++)    {         //loop over orders to find live trade from this EA magic no.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);   //select
      //if from this EA and is a buy or sell, and for this symbol, then
      if(OrderMagicNumber()==MAGICMA && OrderType()<=OP_SELL && OrderSymbol()==Symbol())   {
         double denom = OrderLots()*MarketInfo(OrderSymbol(),MODE_TICKVALUE);
         double profit = OrderProfit()/denom ;
         return(profit);
      }//close if(OrderMagicNumber()..   
   } //close for loop  
}//close func




bool isNewBar()   { //returns whether this is a new Bar. Requires static datetime var. timeOfLastBar
   datetime timeThisBar = Time[0];
   if(timeThisBar != timeOfLastBar)   {
       timeOfLastBar = timeThisBar;
       return(true);
   }
   else return(false);
}//close function isNewBar()


void checkForClose ()   {  //checks for closing signal and calls flattenAll() if true
   //if(s==0.0) flattenAll();
   if(myPosition()==-9) Print("Error signal returned from myPosition()");
   if(es == 0.0) flattenAll();
   return;
}//close function


void checkForOpen()   {
   if(s ==  1.0) goLong();  //if positive signal, go long 
   if(s == -1.0) goShort(); //if negative, go short 
   return;
}//close function


void goLong()  {
   myTicket = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, 0, 0, "myComment", MAGICMA, 0, Blue);
}//close function


void goShort()  {
   myTicket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, 0, 0, "myComment", MAGICMA, 0, Red);
}//close function


bool inTrade()   { //this returns true if position open from this magic number. No pending orders 
   for(int i=0; i<=OrdersTotal(); i++)    {  //loop over orders to find live trade from this EA magic no.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      //if from this EA and is a buy or sell, and for this symbol, then return true
      if(OrderMagicNumber()==MAGICMA && OrderType()<=OP_SELL && OrderSymbol()==Symbol()) return(true);
   } //close for loop
   return(false);
}//close function



int myPosition()   { //this returns +1 for Long, -1 for Short, or 0 for flat. -9 is error! 
                     //based on position open from this magic number. No pending orders 
   int l = 0;        //var to hold long position count
   int s = 0;        //var to hold short position count

   for(int i=0; i<=OrdersTotal(); i++)    {         //loop over orders to find live trade from this EA magic no.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);   //select 
      
      //if from this EA and is a buy or sell, and for this symbol, then return direction
      if(OrderMagicNumber()==MAGICMA && OrderType()<=OP_SELL && OrderSymbol()==Symbol())   {
            if(OrderType()==OP_BUY) l +=1;
            if(OrderType()==OP_SELL) s +=1;     
      }//close if(OrderMagicNumber()..   
   } //close for loop
   if(s==0 && l==0) return(0);
   if(s==0 && l==1) return(1);
   if(s==1 && l==0) return(-1);
   
   return(-9); //error either more than one position for this Symbol and EA or both long and short 
}//close function



void flattenAll()   {
   for(int i=0; i<OrdersTotal(); i++)   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber()== MAGICMA && OrderSymbol()==Symbol() && OrderType()==OP_BUY)   {
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, White); //close long 
      }//close if
      if(OrderMagicNumber()== MAGICMA && OrderSymbol()==Symbol() && OrderType()==OP_SELL)   {
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, White); //close short
      }//close if
   }//close for loop
}//close function


int init()  {
   return(0);
}


int deinit()  {
   return(0);
}