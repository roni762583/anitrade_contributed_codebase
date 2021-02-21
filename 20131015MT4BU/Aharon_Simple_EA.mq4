//+------------------------------------------------------------------+
//|                                             Aharon_Simple_EA.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// 10/27/09 moved comment block out of for loop to enable display when no open positions - ok, but it broke last calculation time
// FIX - last calculation time 



#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

/////////////  Global Scope Variables  //////////////////////

static int start;                                          // this is for start time for this iteration
static int LastStartTime;                                  // this persists to next tick for calculating time between ticks
static int TickCount = 0;                                  // counts ticks - operated on by TickBuffer() function
   
double bids[];                                      // buffer for bid prices 
double asks[];                                      // buffer for ask prices 

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()   {
  //----
  
  LiveComment();   
  
  //SendMail("Msg from EA...", "This is a test of the MT broadcast system...do not be alarmed, this is only a test:)");
  //----
   return(0);
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
   
   TickBuffer();                                           // this is a tick buffer function call
   
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
           "Last calculation time is ", (end-start), " mSec.", "\n",
           "Time between last two ticks (mSec.) ", (start-LastStartTime), "\n",
           "Tick Count is ", TickCount, "\n",
             // "bids buffer...", bids[TickCount - 3], ", ", bids[TickCount - 2], ", ", bids[TickCount - 1], ", ", bids[TickCount], "\n",
           "Bid   ", Bid, "      Ask   ", Ask, "     Spread  ", (Ask-Bid), "             MarginUsed  ", AccountMargin() 
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
   
   double b[], a[];
   
   static bool TenInBuffer = false;
   
   
   b[TickCount] = 1.2345; //Bid;         THIS DOESN'T WORK!!!
   //a[TickCount] = Ask;
   
   //Print("b[TickCount-1]=", b[TickCount-1] );
   
   /*
   bids[TickCount] = MarketInfo(Symbol() ,MODE_BID);
   
   asks[TickCount] = 1.1234;
   */
   /*                                                              THIS HOWEVER MIGHT WORK
   static int start;
   static double bid;
   double t = start - GetTickCount();
   double p = bid - Bid;
   double v = p/t;
   
   Comment( "                                             ", "Time change", DoubleToStr( t, 16), "\n",
            "                                             ", "Price change ", DoubleToStr( p, 16), "\n",
            "                                             ", "Price/Time ", DoubleToStr( v, 16) );
   
   start = GetTickCount();
   bid = Bid;
   */
   
   TickCount = TickCount + 1;
   
   if(TickCount >= 10) TenInBuffer = true;
   else                TenInBuffer = false;
   
   return(0);      

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////