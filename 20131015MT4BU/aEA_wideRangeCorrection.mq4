//                                      aEA_wideRangeCorrection.mq4  |
//+------------------------------------------------------------------+
//this uses BB on Range indicator and trades in opposite direction of extreme range move
/*
GBPUSD  for each hr. bar marked by range exceeding BB (5,2,20), drill own and examine :
a) when during formation of bar did range exceed BB (near close?)-this will aid in designing entry rules
b) what are the typical swing sizes on the way up - this will aid in entry design to time the entry s.t. 
swings can be expected of relative size as indication of posible reaching end of move

enter near end of/extreme of move in opposite direction to catch % of retracement (?~70%)
parameters - 
i)    how much range exceeded BB in pips or %
ii)   % retracement as TP
iii)  some metric for SL such as set no. of pips, pips or % above high of triggering bar
iv)   minimum desired pips present as expected, i.e.check if a 70% retracement of entry bar will provided 
      minimum pips desired
v)    timed exit #of minutes, or number of bars (say within five bars)

-look at 5M chart for range exceeding BB. Note bars that exceed by at least 2 (or X) pips-they may typically
 finish successfully whithin afew minutes rather than a few hours. 
-Also filter out hammers to trade in same direction rather than opposite for a trend for a few bars (~10-15)
-count number of consequtive bars that did not exceed BB-part of indication of consolidation range
*/
#property copyright "Aharon Yehuda"
#property link      ""
//these settings are good on GBPUSD 5M, 10/02-12/03/2012 test IBFX
extern double     xFracOfBarTP      = 0.65;//0.61; // 71%
extern double     bandsDeviation    = 2.0;
extern int        minRangeToTrigger = 100;
extern int        SLptsFromBarExtrm = 2500; //
extern int        pointExceedingBB  = 0;
extern bool       limitTradeTime    = false;
extern int        maxMinutesInTrade = 300;
extern int        minimumPipTarget  = 60;//this will be multiplied by point, so on 5-decimal broker, this will be 10 4-decimal pips, ~=2*spread
extern int        trailPoints       = 40; //on 5 decimal broker
//extern bool TrendTrueCountertrendFalse = false;
extern int        magicNo   = 762583;
//extern double lot = 1;

static datetime   lastBarOpenTime,       //used for isNewBar()
                  latchBarTime,          //to hold bar open time for signal latch to detect if new bar has formed since latch
                  timeOfLastTrade,       //to hold time last traded
                  timeLastTradeBarOpen;  //to hold bar open time of bar last order was executed on
                  
static bool       latch = false;    // this will flag to latch from signal until trailing stop will have reached bar extremum, or new bar forms
static double     lh, ll;           //last highest high, and last lowest low - used for traling stops to catch bar extreme after signal

int               ticket;
double  barsSignalLevels[];         //to store extreme level at time of signal
datetime signalTimes[];             //to store bar start times during which signals occured to 


int init()   {
//   ArrayInitialize(barsSignalLevels, 0.0);
   return(0);
}


int start()  {
  //check if to exit - for testing TP & SL included in OrderSend(), add time limit exit function call here
  if(limitTradeTime)   {
     closeStaleOrders(maxMinutesInTrade);
     //closeOrdersTrailingStop();
  }//close if(limitTradeTime)
  
  
  
  //check if to enter trade, add multiple TF
  double rangeAvg  = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDeviation, 20, 5, 0, 0);
  double upperBB   = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDeviation, 20, 5, 1, 0);
  double rangeAvg1 = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDeviation, 20, 5, 0, 1);
  double upperBB1  = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDeviation, 20, 5, 1, 1);
  
  if(rangeAvg>=upperBB+pointExceedingBB*Point && rangeAvg>=minimumPipTarget*Point && !latch && rangeAvg>=minRangeToTrigger*Point)  {
     latch = true;
     latchBarTime = Time[0];        //to detect if new bar formed since latch
  }//close if(rangeAv...
  
  // this will flag to latch from signal until trailing stop will have reached bar extremum, or new bar forms, before executing trade
  if(latch)   {
     RefreshRates();
     if(Ask>lh) lh = Ask;           //store highest high achieved
     if(Bid<ll) ll = Bid;           //store lowest low achieved
     int bshft = iBarShift(NULL, 0, latchBarTime, true); //return shift of latch bar open time
     if(bshft==-1)   {               //alert error in returning shift of signal bar 
        Alert("error in locating bar shift! debug code! ", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS) );
        //bshft = 1;                //0 return alternative if it conks out
     }//close if(bshft=-1)...
     double ShortSL = NormalizeDouble(High[bshft] + SLptsFromBarExtrm*Point, Digits);
     double ShortTP = NormalizeDouble(High[bshft] - xFracOfBarTP*(High[0]-Low[bshft]), Digits );
     double LongSL  = NormalizeDouble(Low[bshft]  - SLptsFromBarExtrm*Point, Digits); 
     double LongTP  = NormalizeDouble(Low[bshft]  + xFracOfBarTP*(High[bshft]-Low[0]), Digits );
     
     ///if(Close[]-Open[]<minimumPip) hammerOrDoji();
     
     if((Ask+trailPoints*Point<=lh && Bid>Open[bshft]) ){//||    //trailing stop from highest high is hit AND is up bar/s, OR, 
       // (latchBarTime != Time[0] && Close[1]>Open[1])      )  {     //is new bar following up bar ... reset flags & execute order 
        latch = false;
        if(isFlat() && 
           //isNewBar() &&
           //TimeHour(TimeCurrent()) != TimeHour(timeOfLastTrade) &&    //if flat AND didn't trade during this hour 
           Time[0] != timeLastTradeBarOpen &&
           xFracOfBarTP*(High[0]-Low[bshft])>=minimumPipTarget*Point) //if TP meets minimum criteria
              OpenShort(1.0, ShortSL, ShortTP);                       //three param. are: lots, SL, & TP
     }//close if((Ask+tra
     
     if((Bid-trailPoints*Point>=ll && Ask<Open[bshft]) ){//||    //trailing stop from lowest low is hit AND is down bar, OR, 
      //  (latchBarTime != Time[0] && Close[1]<Open[1])      )   {    //is new bar following down bar ... reset flags & execute order 
        latch = false;
        if(isFlat() && 
           //isNewBar() &&
           //TimeHour(TimeCurrent()) != TimeHour(timeOfLastTrade) &&    //if flat AND didn't trade during this hour 
           Time[0] != timeLastTradeBarOpen &&
           xFracOfBarTP*(High[bshft]-Low[0])>=minimumPipTarget*Point) //if TP meets minimum criteria
              OpenLong(1.0, LongSL, LongTP);              //three param. are: lots, SL, & TP
     }//close if((Bid-trai...
  }//close if(latch)...
  
  return(0);
}//close funct.


int OpenLong(double volume, double SL, double TP)   {
  int slippage=3;
  string comment="";
  color arrow_color=Blue;
  int magic=magicNo;

  ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,SL,TP,comment,magic,0,arrow_color);
  if(ticket>0)   {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  {
        Print("Buy order opened : ",OrderOpenPrice());
        timeOfLastTrade = OrderOpenTime();
        timeLastTradeBarOpen = Time[0];
        return(0);
     }
  }
  else   {
     Print("Error opening Buy order : ",GetLastError() );
     return(-1);
  }
}//close function


int OpenShort(double volume, double SL, double TP)   {
  int slippage=3;
  string comment="";
  color arrow_color=Red;
  int magic=magicNo;

  ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,SL,TP,comment,magic,0,arrow_color);
  if(ticket>0)   {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))   {
        Print("Sell order opened : ",OrderOpenPrice());
        timeOfLastTrade = OrderOpenTime();
        timeLastTradeBarOpen = Time[0];
        return(0);
     }
  }
  else   {
     Print("Error opening Sell order : ",GetLastError());
     return(-1);
  }
}


bool isFlat()  { //will return true if no open orders from this EA magic - ignores other orders in system, ignores pending and historical orders 
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            totalOrders++;
         }//close if(OrderSelect...
   }//close for loop
   //Print(" from isFlat(): totalOrders = ", totalOrders);
   if(totalOrders==0) return(true);
   return(false);
}//close isFlat()


//function to detect new bar formed
//datetime lastBarOpenTime; //this is moved to top with other variables
bool isNewBar()   {
   datetime thisBarOpenTime = Time[0];
   if(thisBarOpenTime != lastBarOpenTime) {
      lastBarOpenTime = thisBarOpenTime;
      return (true);
   }//close if()...
   else
   return (false);
}//close isNewBar()...


void closeStaleOrders(int maxMinutes)   {
   double price;
   for(int i=0; i<OrdersTotal(); i++)   {
      //scan open orders and check if any is getting stale according to maxMinutesInTrade
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);             //select order 
      if(OrderType()<2 && OrderMagicNumber() ==  magicNo)   { //if open order (0-buy, 1-sell, other>1), and order from this EA magic number...
         if(OrderType()==0)  price = Bid;
         if(OrderType()==1)  price = Ask;
         if(TimeCurrent()-OrderOpenTime()>=maxMinutes*60)   { //if stale...
            Print("stale order detected...");
            while(!OrderClose(OrderTicket(), OrderLots(), price, 3, Blue)) { //loop till OrderClose() succeeds
               Alert("OrderClose(", OrderTicket(), ") failed with error# ", GetLastError(), ". Retrying..." ); //send alert 
            } //closes while() loop
         }//close if(TimeCurrent()...
      }//close if(OrderType...
   }//close for loop
}//close funct...


int longOrShort()   {  //good only for one active position
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            if(OrderType()==0) return(1);
            if(OrderType()==1) return(-1);
      }//close if(OrderType...      
   }//close for loop
}//close longOrShort()


int deinit(){
  return(0);
}

