//+------------------------------------------------------------------+
//|                               aEA001.mq4                         |
//|  Aharon Zbaida Anitani                                           |
//|                                                                  |
//+------------------------------------------------------------------+

//things to add:

//order mgmt system separated to deal with open positions, hedge requirements
//calculate ma, stddev of vel. per security and store in unique file per security, update and use this for z-score


static int       programStarted;              //to store program start time in millisec.
static int       cts;                         //cycle time stamp, for monitoring pgm. cycle time 
static int       b                 = 0;       //temp var.
static double    firstbid;
       double    a;                           //temp var.
static double    lastBid, lastAsk;            //arrays to hold last rates, 
static double    lastTs;                      //last time stamp
       int       answ;                        //to hold answer regarding success of OrderSend()
static int       index;                       //a var. to hold index of array in time window calculations
static bool      newRate           = false;   //flag to indicate when new rate is received
static bool      posHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      negHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      primed            = false;   //flag to prevent operations without sufficient working time of length time window 
       double    timeStamps[200000];            //to hold last 6000 time-stamps (10 msec. per cycle, at 60 sec. time window)
       double    bids[200000];                  //to hold last 6000 bids
       double    asks[200000];                  //to hold last 6000 asks 
       
extern double    tmWindow          = 5000.0; //time 
extern double    posHighVelThshld  =  0.01;       
extern double    negHighVelThshld  = -0.01;       
extern double    lots              = 0.1;
extern double    SL                = 0.0;
extern double    TP                = 0.0;


int init()   {   
   while(!IsConnected())  {
      Alert("Problem with connection to server...");
      Sleep(5000);
      //WriteToErrorLog();
   } 
   
   ArrayInitialize(timeStamps, 90);
   ArrayInitialize(bids, 0.1);
   ArrayInitialize(asks, 0.1);
   if(IsExpertEnabled())   Comment("Waiting for first tick...");
   if(!IsExpertEnabled())   Comment("Check EA is ENABLED, then wait for first tick...");

}


//moving time window velocity
int start()   {  //will be activated on first tick
   
   programStarted = GetTickCount();
   
   Comment(" ");  //clear comment 
   if(!IsExpertEnabled())   Comment("EAs NOT ENABLED...");
   if(IsExpertEnabled())   Comment("EA started...");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   while(IsExpertEnabled())  { //main program loop, on while EA's play button is on
      
      
      bool bb = RefreshRates();  //returns true if refreshed
      
      //this block stores latest rates and time stamps in array 
      lastTs  = GetTickCount();
      if(Bid!=lastBid || Ask!=lastAsk) newRate = true; //to flag new rate if needed later
      if(true/*Bid!=lastBid || Ask!=lastAsk*/)   {  //every cycle regardless of changes//if bid or ask changed then update arrays 
         lastBid = Bid;
         lastAsk = Ask;                           
         for(int i = 6000; i>0; i--)   {       //all three arrays share the same index to synchronize
            timeStamps[i] = timeStamps[i-1];  //this is to shift the stack to make room for new time stamp data
            bids[i]       = bids[i-1];        //this is to shift the stack to make room for new bid data
            asks[i]       = asks[i-1];        //this is to shift the stack to make room for new ask data
         }//closes for loop
         //store last ts, bid, ask rates in the zero index row
         // i = 0 at this point 
         timeStamps[i]    = lastTs;          //
         bids[i]          = lastBid;         //
         asks[i]          = lastAsk;         //   
      }//closes if(true)
      
      
      //this block set primed var. on: make sure pgm. working at least as long back as time window 
      if(!primed)   {
         Comment("Time to start " + DoubleToStr(tmWindow+programStarted-lastTs,0) + " millisec.");
         if(lastTs-programStarted >= tmWindow) primed = true; //this is to flag ok to operate after pgm has been running as long as the time window 
      }
      
      if(primed)   {//this block will only run after prog. has running for length of timewindow
      
         //this block searches for index where time stamp equals beggining of moving time window 
         double dd     = lastTs-tmWindow;  //this is delta from last time stamp to begginig of moving time window
         index         = ArrayBsearch(timeStamps, dd, WHOLE_ARRAY, 0, MODE_DESCEND);  //array index corresponding to beggining of time window 
      
      
         //this block calculates velocity
         double bidvel = (lastBid-bids[index])/(tmWindow/1000.0);
               
      
         //displays on chart 
         Comment("Time Window [sec.]: " + DoubleToStr(tmWindow/1000.0,1) + " ,  Bid Velocity [pps]: " + bidvel + "\n" +
                 "Threshold setting: " + posHighVelThshld + " ,  " + negHighVelThshld);
         
         
         if(newRate)  {
            newRate = false;
            Print("timestamp[",index,"] ", timeStamps[index], ",  error of movTmWndw = ", tmWindow-(lastTs-timeStamps[index]), " mSec." );
         }
         
         answ = 0; // to make sure answ var. doesn't have value from prev. iteration
         
         //detect high velocity events
         if(bidvel>=posHighVelThshld && !posHighVelTrig)   {  //to detect positive high velocity event
            Alert("Pos. High Velocity ! " + bidvel + " " + Symbol());
            if(!IsTradeContextBusy()) {  //if trade context is not busy and signal has not previously been triggered send order
               if(noneOpen()) answ = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, SL, BuyTP(), NULL, 762583, 0, CLR_NONE); 
               
               //if(answ>0) OMS(answ); //to pass ticket # filled to order management system function
               
               if(answ==-1) Print("Buy Order did not go through, Error code ", GetLastError()); 
            } //close if() of order sending block
            posHighVelTrig = true; 
            negHighVelTrig = false;
         } //close if() of posHighVel...block
         //
         if(bidvel<=negHighVelThshld && !negHighVelTrig)    {  //to detect negative high velocity event
            Alert("Neg. High Velocity ! " + bidvel + " " + Symbol());
            if(!IsTradeContextBusy()) {  //if trade context is not busy and signal has not previously been triggered send order
               if(noneOpen()) answ = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, SL, SellTP(), NULL, 762583, 0, CLR_NONE); 
               //if(answ>0)
               if(answ==-1) Print("Sell Order did not go through, Error code ", GetLastError()); 
            }//close if() of SELL order sending block
            negHighVelTrig = true;  //set flag true
            posHighVelTrig = false;
         } //close if() of negHighVel...block
         
         if(bidvel<posHighVelThshld && bidvel>negHighVelThshld)   {
            negHighVelTrig = false;  //set flags to false
            posHighVelTrig = false;
         }
      
      }//close if() primed
      if(GetTickCount()- cts > 30) Print("Cycle time: ", GetTickCount()- cts , " mSec."); //print program cycle time 
      cts = GetTickCount();  //cycle time stamp 
   }   //while loop, main program loop
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}//close start()



double BuyTP()   {
   double tp;
   if(TP == 0.0) tp = NormalizeDouble((Ask+(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point)),Digits);
   Print("Buy tp = ", tp);
   return(tp);
}


double SellTP()   {
   double tp;
   if(TP == 0.0) tp = NormalizeDouble((Bid-(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point)),Digits);
   Print("Sell tp = ", tp);
   return(tp);
}


bool noneOpen()   {
   int total=OrdersTotal();
   if(total==0) return(true);
   return(false);
}

//** THIS JUNK IS FOR THE FILE WRITER PORTION TO STORE STATS. BTWN SESSIONS **//
/*   for(int pos=0;pos<total;pos++)   {
      int handle=FileOpen("OrdersReport.csv",FILE_WRITE|FILE_CSV,"\t");
  if(handle<0) return(0);
  // write header
  FileWrite(handle,"#","open price","open time","symbol","lots");
  int total=OrdersTotal();
  // write open orders
  for(int pos=0;pos<total;pos++)
    {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     FileWrite(handle,OrderTicket(),OrderOpenPrice(),OrderOpenTime(),OrderSymbol(),OrderLots());
    }
  FileClose(handle);
      
   }
*/


int deinit() {
   if(!IsExpertEnabled())   Comment("EAs NOT ENABLED...");
}
//------------------------------------------------------------------