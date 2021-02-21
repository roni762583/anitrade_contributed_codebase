//+------------------------------------------------------------------+
//|                                            Aharon_Simple_EA2.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                             Aharon_Simple_EA.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// 10/27/09 moved comment block out of for loop to enable display when no open positions - ok, but it broke last calculation time
// 
// 11/010/09 in Aharon_Simple_EA2.mq4 added check for registered account to prevent testing from spiling into live account if switched ++


#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

/////////////  Global Scope Variables  //////////////////////

static int start;                                          // this is for start time for this iteration
static int LastStartTime;                                  // this persists to next tick for calculating time between ticks
static int TickCount = 0;                                  // counts ticks - operated on by TickBuffer() function
static int TbtwnLastTwoTicks[5000];                                 // time btwn two ticks
//this will later need to be in a loop for longer duration runs that will reuse the array elements
double Bs[5000], As[5000];                                  // arrays for bids and asks
double Bn[5000], An[5000];                                  // MA array for Bids and Asks
int Ds[5000], Dn[5000];                                     // array for timestamps, and averages
int Dnmom[5000];                               




bool Work = true;
bool EAOn4Acc = true;

extern string RegisteredAccounts = "90330565, 00000000, 10376820";   //list of account numbers approved for this strategy i.e. demo acct.
extern int MinBarsInChart = 100;
extern double m = 3.0;                                   // length of MA for ticks, must be greater than zero!
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()   {
  //----
  PreliminaryProcessing();
  /*
  if( StringFind(RegisteredAccounts, DoubleToStr(AccountNumber(), 0), 0) == -1)   {          //if not account registered for this strategy, get out!
     Alert("Unregistered Account!" + "\n" + "Current Active account no.: " + AccountNumber());
     EAOn4Acc = false;
     return(0);
  } */
  
  LiveComment();   
  
  //SendMail("Msg from EA...", "This is a test of the MT broadcast system...do not be alarmed, this is only a test:)");
  //----
   return(1);
}
  
  
  
  
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
   //----
   
   //----
   return(0);
}
 
 
  
  
//+------------------------------------------------------------------+
//| expert start function - this is called every new tick            |
//+------------------------------------------------------------------+
int start()  {

   start = GetTickCount();                                 //Get time stamp for beggining of start() function;

   if(PreliminaryProcessing() == -1) return;               //check for minimal conditions for EA to work 
   
                                              // this is a tick buffer function call
   
   
   TbtwnLastTwoTicks[TickCount] = start-LastStartTime;                // TbtwnLastTwoTicks displayed in livecomment() func., and tickbuffer() funct
   
   TickBuffer();                                           //should be called after TbtwnLastTwoTicks assigned 
   
   LiveComment();                                          // should be call last among functions due to its display of run time
   
   LastStartTime = start;                                  // save start time for next iteration for time between ticks
   
   return(0);
}



//////////////////////////////////////////////////////     LiveComment function   //////////////////////////////////////////
//                              this function displays updated trading related information as a comment on chart
//                              this function calls: GetLongLots(), and GetShortLots() user defined functions
int LiveComment()   {
   
   //moved   start = GetTickCount();   line to start() function 
   
   int ot = OrdersTotal();                                 //this is number of open orders (executed + pending)
   int i, pos, sc, f =0;
   
   double longlots, shortlots;
   double lnet;
   double ab = AccountBalance();
   double ae = AccountEquity();
   
   string oss, os[];
   string sym, usedsym;
   
   bool morethanonesymbol = false;
 


   //loop over orders - main loop
   for(pos=0;pos<=ot;pos++) {        //ok loops over number of order entries   //changed to <= instead of < to enter loop when 0 orders exist 10/27/09           
   
   
      
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;  //selects order, or pops to next iteration
         
      if(StringFind(usedsym, OrderSymbol(), 0)== -1 )   {  //if sym was not found in usedsym: conditionally asigns as follows...
         
         sym = OrderSymbol();                              //asigns sym value of symbol order in queue 
         usedsym = usedsym + " ,  " + sym;                          //adds sym to usedsym (list of symbols submitted to processing         
         
         //ok, now each symbol is only selected once up to here
         
         longlots  = GetLongLots(sym);
         shortlots = GetShortLots(sym);
         
         oss = oss + sym + "   long: " + DoubleToStr(longlots, 2) + 
                           "   short: " + DoubleToStr(shortlots, 2) + 
                           "   net : " + DoubleToStr((longlots - shortlots), 2) +
                           "\n";   
      }
      
      //int end = GetTickCount();  MOVED OUT OF LOOP TO FIX LAST CALC. TM.

   }
   //Sleep(1000);
   //Print(Point);
   int end = GetTickCount();
      
   //Puts comment in top left-hand of chart window
   Comment("Last tick server time ", TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS), "\n",
           "Local machine time ", TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS), "\n",
           "Open Positions[lots]: ", "\n", oss,            //oss terminates w/ caridge-return char.
           "Account Balance: ", ab, "\n",
           "Account Equity:  ", ae, "\n",
           "Last calculation time is  ", (end-start), "   mSec.", "\n",
           "Time between last two ticks (mSec.)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!FIX ", TbtwnLastTwoTicks[TickCount], "\n",
           "Avg. Tm. Btwn. Ticks (mSec.) ", Dn[TickCount], "   ...mom. of avg. tm. btwn. ticks ", Dnmom[TickCount], "\n",
           "Tick Count is ", TickCount, "\n",
           "Over the last  ", m, "  ticks:", "\n",
           "                                  Avg. Bid    ", Bn[TickCount], "                Avg. Ask    ", An[TickCount], "\n",
           "                                          Bid    ", Bid, "                        Ask    ", Ask, "\n",
           "Difference (Price-Avg.)                  ", Bid-Bn[TickCount], "                     Difference             ", Ask-An[TickCount], "\n",
           "Percent Difference        ", (Bid-Bn[TickCount])/MathMax(Bn[TickCount],0.00001)*100, 
           " / ",                        (Ask-An[TickCount])/MathMax(An[TickCount],0.00001)*100, "\n",
           "     Spread  ", (Ask-Bid), "             MarginUsed  ", AccountMargin() 
           ); 
   
   return(0);
   
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////     GetLongLots function   //////////////////////////////////////////
double GetLongLots(string sm)   {
   
   double longsum = 0.0;
   
   int ot = OrdersTotal();                                 //this is number of open orders (executed + pending)
   
                                                           
   for(int pos=0;pos<ot;pos++) {                           //loop over open orders and sum up longs for given symbol 
   
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;  //selects order, or pops to next iteration
      
      if(OrderSymbol() == sm)   {                          //if selected order is for desired symbol...process further
         
         if(OrderType()==OP_BUY) longsum=longsum+OrderLots();   //if this order is long, add it to longs' sum
         
      }
   }
   
   return(longsum);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






//////////////////////////////////////////////////////     GetShortLots function   //////////////////////////////////////////
//                                  this func. returns total open short lots for symbol as positive number

double GetShortLots(string sm)   {
   
   double shortsum = 0.0;
   
   int ot = OrdersTotal();                                 //this is number of open orders (executed + pending)
   
                                                           
   for(int pos=0;pos<ot;pos++) {                           //loop over open orders and sum up longs for given symbol 
   
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;  //selects order, or pops to next iteration
      
      if(OrderSymbol() == sm)   {                          //if selected order is for desired symbol...process further
         
         if(OrderType()==OP_SELL) shortsum = shortsum + OrderLots();   //if this order is long, add it to longs' sum
         
      }
   }
   
   return(shortsum);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////     TickBuffer() function   //////////////////////////////////////////
//                                  this func. buffers tick data

int TickBuffer()   {

//   double Bs[5000], As[5000];      //this will later need to be in a loop for longer duration runs that will reuse the array elements
//   double Bn[5000], An[5000];
   
   TickCount = TickCount + 1;
   
   Bs[TickCount] = StrToDouble(DoubleToStr(Bid,Digits));          //bids
   As[TickCount] = StrToDouble(DoubleToStr(Ask,Digits));          //asks ; both converted to string type to make it work, didn't work as double 
   Ds[TickCount] = start;                                         //int milisec time stamp of last tick
   
   if(TickCount <= m)   {                                         //in the case not all m initial ticks have yet arrived
      Bn[TickCount] = StrToDouble(DoubleToStr(Bid,Digits));       //moving avgs.
      An[TickCount] = StrToDouble(DoubleToStr(Ask,Digits));
      Dn[TickCount] = TbtwnLastTwoTicks[TickCount];                                      //should be time of last tick if less than m ticks
      
      Print("TbtwnLastTwoTicks[",TickCount,"]",TbtwnLastTwoTicks[TickCount]);
   }

   if(TickCount > m)   {                                            //calculate averages
      Bn[TickCount] = Bn[TickCount-1] + (Bs[TickCount]-Bs[TickCount-StrToInteger(DoubleToStr(m,0))]) / m ;    //bid moving average over m last ticks
      An[TickCount] = An[TickCount-1] + (As[TickCount]-As[TickCount-StrToInteger(DoubleToStr(m,0))]) / m ;    //ask moving average over m last ticks
      Dn[TickCount] = Dn[TickCount-1] + (TbtwnLastTwoTicks[TickCount]-TbtwnLastTwoTicks[TickCount-StrToInteger(DoubleToStr(m,0))]) / m ;    //moving average of time tbwn. ticks over m last ticks
      Dnmom[TickCount] = Dn[TickCount]-Dn[TickCount-1];
      
   }
   
   return(0);      
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////     PreliminaryProcessing() function   //////////////////////////////////////////
//                                  this func. checks for conditions for functionin

int PreliminaryProcessing()   {
      
   if( StringFind(RegisteredAccounts, DoubleToStr(AccountNumber(), 0), 0) == -1)   {          //if account not registered for this strategy, get out!
     Alert("Unregistered Account!" + "\n" + "Current Active account no.: " + AccountNumber());
     EAOn4Acc = false;
     return(-1);
   }   
   if(Work == false)   {                                   //If flag off, get out
      Alert("Work flag OFF! Activities Suspended");
      return(-1);
   } 
   if(MinBarsInChart > Bars)   {
      if(GetMoreHistory() == -1) Alert("Not enough bars in the window. EA doesnt work.");
      return(-1);   
   }
   
   return(0);      
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////     GetMoreHistory() function   //////////////////////////////////////////
//                                  this func. will attempt to populate chart window with minimal bars for strategy

int GetMoreHistory()   {
   // Place code to get more history here, if successfull return 0
   return(-1);       
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////