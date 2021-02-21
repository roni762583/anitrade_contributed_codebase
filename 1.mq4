//+------------------------------------------------------------------+
//|                                                            1.mq4 |
//                       written by: Aharon Zbaida Anitani           |
//                       Copyright � 2012, Anitani Software          |
//|                                        http://www.anitani.com    |
//+------------------------------------------------------------------+
//last touch: 04/18/2012

//redesign: so EA will run on many pairs to detect conditions, and set a global variable to communicate opportunity. One of the EAs running will serve
//as central OMS - this will select best trades from available opportunities, allocate capital, monitor open and pending trades
//all orders to go through OMS - there shall be the flag to switch trading on and off

// This will serve as the active development EA to initially combine moving time window calculations (as set forth in aEA001a.mq4,)
// auto-S/R calculations of aEA002c.mq4, and error caching and structure of book example
//
//Auto S/R uses zigzag indicator, and gets last 10 extremums of each of the large time frames: mnth, wk, day, hour, 15min.

//then rank each level based on TF (higher TF more significant), based on age (recent is more meaningfull), see book for other ranking criteria
//then define a S/R zone of X%, or X pips above and below level
//overlapping zones are additive, thus defining strength of S/R levels

// store highs and lows of zigzag indicator in separate arrays for referencing questions like "is current price above prev. zigzag high?"
// do like an ASI based on breaking through prev. market reversal values
//////////////////////////////////////////////////////////////////////////
/*
build bolinger bands for velocity EA
graphical indicator of velocity having scale of BB
write to file data history to preserve session to session

debug ASI ind. EA

-Trend
-velocity-BB on Vel. indicator
*/
//////////////////// comments from aEA001a.mq4 ///////////////////////////
//update: 02/21/2012 this version will seek to incorporate auto-S/R levels from aEA002c.mq4, also 
//add arrays to hold moving time-window velocities for statistical analysis and acceleration calculation
//need better graphcal indicator of velocity, and its statistical ranking (z-score, and thresholds for event signal)
//also incorporate features from book example EA like error handling
//BuyTP(), and similar functions to return targets for TP & SL based on strategy, or send long TF TP & SL targets with 
//order that are based on S/R levels, while this program to monitor positions in real-time to exit positions based on potential P/L
//thereby preventing SL gunning by broker
// also need to add file writing to remember where it was after crash/siesta
//very important: to monitor market breaths, create arrays, and indicator on chart, of last extremums in velocity, both high and low, 
//like a water-line mark to be re-tested each breath
//send email when a trade opens and when it closes with summary
//order mgmt system separated to deal with open positions, hedge requirements
//calculate ma, stddev of vel. per security and store in unique file per security, update and use this for z-score
//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//moving time window calculations for price acceleration, range/volatility, volatility rate, volatility acceleration, tick chart w/ MA

///////////////////////////////////////////////////////////////////////////
//KEY LEVER (S/R)ALGO
//-if at least three (3) maxima/minima 'touch' a price level within certain distance (price band +/-),
//the level is established as key level,
//-the more touches at key level, the more likely it is to repeat
//-the more frequent touches (number of touches per minimum time to cover span of touches: earliest touch to latest touch
//-the more recent the touch the more meaningful the level is
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
//build in data logger / writer for data: bid, ask, msec. timestamp, pair, moving window velocity
//////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
//build in log file writter and alert for offline due to no connection
///////////////////////////////////////////////////////////////////////////

// AutoHierarchy refers to EA instances aligning under the head EA with OMS functionality




#property copyright "Copyright � 2012, anitani software solutions"
#property link      "http://www.anitani.com"

//user input variables
extern int barsBack = 0;
extern int       magic             = 762583; //this is magic number for this EA, a specific entery strategy number to be appended to it (3-digits)
extern double    tmWindow          = 3000.0;  //time[msec.] 60000
extern double    posHighVelThshld  =  0.01500;       
extern double    negHighVelThshld  = -0.01500;       
extern double    lots              = 0.01;
extern double    useSL             = true;
extern double    useTP             = true;
extern double    SL                = 0.0;
extern double    TP                = 0.0;
extern double    n                 = 7;     //period of MA on bidvelsumavg
extern int       slippage          = 3;
extern bool      emailAlerts       = false; //whether to email alerts
extern bool      useTimeWindow     = false; //added 08/13/12 to allow shutting off this feature for testing other parts

//static variables
static datetime  LatchTime,
                 gvd;                         //this is to hold datetime of setting of Global Variable for AutoHierarchy()
static int    j=0;
static bool   firstRun = true;
static string s;
static double z = 0.0, zp=0.0;
static int       handle = -2;                 //handle for file reading/writing, -2 is initialized value
static bool      openned = false;             //flag to indicate if file already openned this session
static bool      prevRead = false;            //to flag if preveously read, then don't read again
static string    filename;                    // file naming: broker,pair
static double    velsum, velcount;            //vars to hold vel. sum and count for stats funct. 
static double    sumread   = 0.0;             //to hold vel. sum read from file 
static double    countread = 0.0;             //to hold vel. count read from file 
static double    bidvel    = 0.0;             //to hold bid velocity
static double    bidvelsum = 0.0;             //to hold bid velocity sum
static double    bidvelsumavg = 0.0;          //bidvelsumavg
static double    bidvel2   = 0.0;             //02/28/'12 to experiment with while constructing
static int       index;                       //a var. to hold index of array in time window calculations
static bool      newRate           = false;   //flag to indicate when new rate is received
static bool      posHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      negHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      primed            = false;   //flag to prevent operations without sufficient working time of length time window 
static double    lastBid, lastAsk;            //arrays to hold last rates, 
static double    lastTs;                      //last time stamp
static int       programStarted;              //to store program start time in millisec.
static int       cts;                         //cycle time stamp, for monitoring pgm. cycle time 
static int       b                 = 0;       //temp var.
static int       dct = 0.0;                   //directional count: counts pos. & neg. velocities
static double    firstbid, 
                 gv = 0.0;                    //stores global variable value for AutoHierarchy
//variables
       double    a;     //temp var.
       double    timeStamps[6000];            //to hold last 6000 time-stamps (10 msec. per cycle, at 60 sec. time window)
       double    bids[6000];                  //to hold last 6000 bids
       double    asks[6000];                  //to hold last 6000 asks        
       double   z15levels[15], z60levels[15], z1440levels[15], z10080levels[15], z43200levels[15]; //levels are zigzag prices
       double   levels[100];  //02/28/'12 to get levels from all level arrays 
       
       datetime z15times[15],  z60times[15],  z1440times[15],  z10080times[15],  z43200times[15];  //timestamp of bar 
       
       bool     z15HL[15],     z60HL[15],     z1440HL[15],     z10080HL[15],     z43200HL[15];     //  in dicates maxima=true, and Minima=false
       bool      Work              = true;
                
       int    i, limit, k=0, TF;
       int       MinBars           = 50;
       int       answ;                        //to hold answer regarding success of OrderSend()
       int       StopLoss, TakeProfit; //is this correct var. type?

       string    Symb;
int Tipxxxxx;
double Price, Lot;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()  {
   //LatchTime = TimeCurrent();
   int ah = AutoHierarchy();
   if(ah==1.0) 
   
   ObjectsDeleteAll();//clear chart of ALL objects - change to only clean out items assoc. w/ this EA
   firstRun = true;   //set flag to indicate program is in first cycle
   
   //check broker connection
   while(!IsConnected())  {
      Alert("Problem with connection to server...");
      Sleep(5000);
      //WriteToErrorLog();
   } 
   
   //initialize arrays
   ArrayInitialize(timeStamps, 90);
   ArrayInitialize(bids, 0.1);
   ArrayInitialize(asks, 0.1);
   if(IsExpertEnabled())   Comment("Waiting for first tick...");
   if(!IsExpertEnabled())   Comment("Check EA is ENABLED, then wait for first tick...");

   filename = AccountCompany()+ Symbol()+DoubleToStr(MathRound(tmWindow),0);  //unique file to store stats
}//close init()



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()  {
   //variables
   int
   Total,                                                  // Amount of orders in a window
   Tipe=-1,                                                 // Type of selected order (B=0,S=1)
   Ticket;                                                 // Order number

   double
   Lot,                                                    // Amount of lots in a selected order
   Lts,                                                    // Amount of lots in an opened order
   Min_Lot,                                                // Minimal amount of lots
   Step,                                                   // Step of lot size change
   Free,                                                   // Current free margin
   One_Lot,                                                // Price of one lot
   Price,                                                  // Price of a selected order
   SL,                                                     // SL of a selected order
   TP,                                                     // TP \u0437\u0430 a selected order
   signal1,                                                // signal from iCustom()
   signal0;
   
   bool
   Ans =false,                                             // Server response after closing
   Cls_B=false,                                            // Criterion for closing Buy
   Cls_S=false,                                            // Criterion for closing Sell
   Opn_B=false,                                            // Criterion for opening Buy
   Opn_S=false;                                            // Criterion for opening Sell
   
   // Preliminary processing
   if(Bars < MinBars)  {                                   // Not enough bars - have to manually check it is enough in chart of called TF superceeding chart TF     
      Alert("Not enough bars in the window. EA doesn\'t work.");
      return;                                              // Exit start()
   }
   
   //check for critical alert
   if(Work==false)   {                                     // Critical error
      Alert("Critical error. EA doesn\'t work. (variable Work is false");
      if(emailAlerts) SendMail("EA1-Critical Error!", "Critical error. EA doesn\'t work. (variable; Work=false)");
      return;                                              // Exit start()
   }


   // Call Order Management System (OMS) function to account for present orders/positions, and check for exit conditions
   OMS();
   
   


   //----------------// Closing orders
   while(true)   {                                         // Loop of closing orders
     
      if (Tipxxxxx==0 && Cls_B==true)  {                        // Order Buy is open, and there is criterion to close
      
         Alert("Attempt to close Buy ",Ticket,". Waiting for response..");
         
         RefreshRates();                                   // Refresh rates
         
         Ans = OrderClose(Ticket,Lot,Bid,2, LightBlue);    // Closing Buy
         
         if (Ans==true)    {                               // Success :)
           
            Alert ("Closed order Buy ", Ticket);
            break;                                         // Exit closing while loop
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      if (Tipxxxxx==1 && Cls_S==true)   {                       // Order Sell is open, and there is criterion to close
      
         Alert("Attempt to close Sell ", Ticket, ". Waiting for response..");
         
         RefreshRates();                                   // Refresh rates
         
         Ans = OrderClose(Ticket, Lot, Ask, 2, LightPink); // Closing Sell
         
         if (Ans==true)   {                                // Success :)
           
            Alert ("Closed order Sell ",Ticket);
            
            break;                                         // Exit closing loop
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      break;                                               // Exit while
   }


   // Order value
   RefreshRates();                                         // Refresh rates
   Min_Lot = MarketInfo(Symb, MODE_MINLOT);                // Minimal number of lots
   Free    = AccountFreeMargin();                          // Free margin
   One_Lot = MarketInfo(Symb, MODE_MARGINREQUIRED);        // Price of 1 lot //this is price for full lot, whereas min-lot may be 0.01
   Step    = MarketInfo(Symb, MODE_LOTSTEP);               // Step is changed
   
   /////////////////////THIS NEEDS WORK TO CONFIRM PROPER FUNCTIONING OF CALCULATION, AND INCORPORATING KELLY CRITERION
   //                            FOR NOW WORK STRICTLY WITH 0.01 LOTS, THE MINIMUM
   // < changed to >   If lots are set,      ... at this stage work strictly with one micro-lot
     
      Lts = lots; //use user input for lot size
   
   //else  // else, use % of free margin             ... need to verify this works correctly with micro lots, kelly etc.
   //      Lts = MathFloor(Free*Prots/One_Lot/Step)*Step;       // For opening
   //if(Lts < Min_Lot) Lts=Min_Lot;               // > changed to <    Not less than minimal
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
   if (Lts*One_Lot > Free)  {                              // Lot larger than free margin
      Alert(" Not enough money for ", Lts," lots");
      return;                                   // Exit start()
   }
   
//--------------------------------------------------------------- 8 --
   
   // Opening orders
   while(true)   {                                         // Orders closing loop
     
      if ( Opn_B==true)    {                    // No new orders +Total==0 &&
                                                           // criterion for opening Buy
         RefreshRates();                                   // Refresh rates
         
         SL = Bid - New_Stop(StopLoss) * Point;            // Calculating SL not to be less than minimum allowed
         
         TP = Bid + New_Stop(TakeProfit) * Point;          // Calculating TP of opened not to be less than minimum allowed
         
         Alert("Attempt to open Buy. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_BUY, Lts, Ask, 2, SL, TP, NULL, 0, 0, Blue);   //Opening Buy
         
         if (Ticket > 0)   {                               // Changed to > , Success :)
            Alert ("Opened order Buy ", Ticket);
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      if (  Opn_S==true)   {                     // No opened orders +Total==0
                                                           // criterion for opening Sell
         RefreshRates();                                   // Refresh rates
         
         SL = Ask + New_Stop(StopLoss)*Point;              // Calculating SL of opened
         
         TP = Ask - New_Stop(TakeProfit)*Point;            // Calculating TP of opened

         Alert("Attempt to open Sell. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_SELL, Lts, Bid, 2, SL, TP, NULL, 0, 0, Red);   //Opening Sell
         
         if (Ticket > 0)   {                               // changed to >,   Success :)
           
            Alert ("Opened order Sell ",Ticket);
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying

         return;                                           // Exit start()
      }
      
      break;                                               // Exit while
   }                                                       // close while loop
   
//--------------------------------------------------------------- 9 --
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(firstRun)  {                        //this block of code will run once initially
      for(i=0; i<=4; i++)   {             // loop over TF's
         
         if(i==0)  {                      // first case 15min. TF
               TF=15;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z15levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z15HL[j] = true;   // if maxima
                     if(z<zp) z15HL[j] = false;  // if minima
                     z15times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               }  //closes for(k=0...
         } //closes if(i==0...
         j=0;
         zp = 0.0;
         
         if(i==1)  {                      // first case 60 min. TF
               TF=60;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z60levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z60HL[j] = true;   // if maxima
                     if(z<zp) z60HL[j] = false;  // if minima
                     z60times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;         
         
         if(i==2)  {                      // first case 60 min. TF
               TF=1440;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z1440levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z1440HL[j] = true;   // if maxima
                     if(z<zp) z1440HL[j] = false;  // if minima
                     z1440times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;
         
         if(i==3)  {                      // first case 60 min. TF
               TF=10080;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z10080levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z10080HL[j] = true;   // if maxima
                     if(z<zp) z10080HL[j] = false;  // if minima
                     z10080times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;         
         
         if(i==4)  {                      // first case 60 min. TF
               TF=43200;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z43200levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z43200HL[j] = true;   // if maxima
                     if(z<zp) z43200HL[j] = false;  // if minima
                     z43200times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;
                
      }//close for loop
         
      firstRun = false;
      
   }//close if(firstRun)

   if(!firstRun)  {                                                   //this part will run on subsequent incomming ticks
      for(k=0; k<11; k++)   {
               s = "SR15_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z15levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Blue);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR60_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z60levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Green);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR1440_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z1440levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Yellow);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR10080_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z10080levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Red);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR43200_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z43200levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Purple);
      }  //close for k
      
      
      //send ftp report test
      WindowScreenShot("screenshot.gif",640,480);
      SendFTP("screenshot.gif");
      //SendFTP("screenshot.html");

      
      
      
 programStarted = GetTickCount();
   
   Comment(" ");  //clear comment 
   if(!IsExpertEnabled())   Comment("EAs NOT ENABLED...");
   if(IsExpertEnabled())   Comment("EA started...");

   
   while(IsExpertEnabled())  { //main program loop, on while EA's play button is on
      
      
      bool bb = RefreshRates();  //returns true if refreshed
      
      //this block stores latest rates and time stamps in array 
      lastTs  = GetTickCount();
      if(useTimeWindow )  {
         if(Bid!=lastBid || Ask!=lastAsk) newRate = true; //to flag new rate if needed later
         if(true)   {  //every cycle regardless of changes//if bid or ask changed then update arrays 
            lastBid = Bid;
            lastAsk = Ask;                           
            for(i = 6000; i>0; i--)   {       //all three arrays share the same index to synchronize
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
      
         if(primed)   {//this block will only run after prog. has been running for at least length of time of timewindow
      
            //this block searches for index where time stamp equals beggining of moving time window 
            double dd     = lastTs-tmWindow;  //this is delta from last time stamp to begginig of moving time window
            index         = ArrayBsearch(timeStamps, dd, WHOLE_ARRAY, 0, MODE_DESCEND);  //array index corresponding to beggining of time window 
      
      
            //this block calculates velocity
            bidvel = (lastBid-bids[index])/(tmWindow/1000.0); //02/28/'12 changed from 1000 to 1
         
        

            //displays on chart
            Comment("Time Window [sec.]: " + DoubleToStr(tmWindow/1000.0,1) + "\n" + 
                    "Bid Velocity [pps]: " + bidvel + "\n" +
                    "Directional Count = " + dct + "\n" +
                    "Bid Velocity Sum: " + bidvelsum + "\n" +
                    "bidvelsumavg[" + n +"]: " + bidvelsumavg + "\n" +
                    "Threshold setting: " + posHighVelThshld + "  <--->  " + negHighVelThshld);
         
         
            if(newRate)  {
               newRate = false;
               Stats();
               Print("timestamp[",index,"] ", timeStamps[index], ",  error of movTmWndw = ", tmWindow-(lastTs-timeStamps[index]), " mSec." );
               if(bidvel<0.0) dct = dct - 1.0;
               if(bidvel>0.0) dct = dct + 1.0;
               bidvelsum = bidvelsum + bidvel;
               bidvelsumavg = bidvelsumavg - (bidvelsumavg/n) + (bidvel/n);
               if(bidvelsumavg>bidvelsum) {//going down
                  ObjectDelete("i1");
                  ObjectCreate("i1",OBJ_ARROW,0,Time[0], High[0]+Point*100);
                  ObjectSet("i1", OBJPROP_ARROWCODE, 242);
                  ObjectSet("i1", OBJPROP_COLOR, Blue);
                  ObjectSet("i1", OBJPROP_XDISTANCE, 150);
                  ObjectSet("i1", OBJPROP_YDISTANCE, 150);
               }//close if(bidvel...)
               
               if(bidvelsumavg<bidvelsum) {//going up
                  ObjectDelete("i1");
                  ObjectCreate("i1",OBJ_ARROW,0,Time[0],High[0]+Point*100);
                  ObjectSet("i1", OBJPROP_ARROWCODE, 241);
                  ObjectSet("i1", OBJPROP_COLOR, Red);
                  ObjectSet("i1", OBJPROP_XDISTANCE, 150);
                  ObjectSet("i1", OBJPROP_YDISTANCE, 150);
               }
            } //close if(newRate)
         
            answ = 0; // to make sure answ var. doesn't have value from prev. iteration
         
            //detect high velocity events
            if(bidvel>=posHighVelThshld && !posHighVelTrig)   {  //to detect positive high velocity event
               Alert("Pos. High Velocity ! " + bidvel + " " + Symbol());
               if(!IsTradeContextBusy()) {  //if trade context is not busy and signal has not previously been triggered send order
                  if(okToOpen()) answ = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, BuySL(), BuyTP(), NULL, magic, 0, CLR_NONE); 
               
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
                  if(okToOpen()) answ = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, SellSL(), SellTP(), NULL, magic, 0, CLR_NONE); 
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
      } //close if(useTimeWindow)
      
      if(GetTickCount()- cts > 30) Print("Cycle time: ", GetTickCount()- cts , " mSec."); //print program cycle time 
      cts = GetTickCount();  //cycle time stamp 
   }   //while loop, main program loop

 //22///////////////////////////////////////////////////////////////////////////////////////////////////////
 
   }//close if !firstRun
   return(0);
}//close start()


/////////////////////////////////////////////////ok//////////////////////////////////////////////////////////////////////////////////////
double BuyTP()   {
   double tp;
   if(!useTP) return(0.0);                                 //if TP is not to be used, return zero
                                                           //next, if TP is to be used, and supplied as Zero, return minimal T/P
   if(TP == 0.0 && useTP) tp = NormalizeDouble((Ask+(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point)),Digits);
   if(TP != 0.0)          tp = NormalizeDouble((Ask+TP*Point),Digits);
   Print("Buy tp = ", tp);
   return(tp);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////ok///////////////////////////////////////////////////////////////////////
double SellTP()   {
   double tp;
   if(!useTP) return(0.0);  // see comments above
   if(TP == 0.0  && useTP) tp = NormalizeDouble(Bid - MarketInfo(Symbol(), MODE_STOPLEVEL)*Point, Digits);
   if(TP != 0.0)           tp = NormalizeDouble(Bid - TP*Point, Digits);
   Print("Sell tp = ", tp);
   return(tp);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////ok//////////////////////////////////////////////////////////////////////////////////////
double BuySL()   {
   double sl;
   if(!useSL) return(0.0);  //if SL not to be used, return zero
   if(SL == 0.0 && useSL) sl = NormalizeDouble(            // if SL is to be used, but given as zero, return minimal S/L...
                                  (   Ask -                // Buy S/L, is Ask - spread and stoplevel points, normalized for output
                                         (   MarketInfo(Symbol(), MODE_SPREAD) + 
                                             MarketInfo(Symbol(), MODE_STOPLEVEL)   ) * Point
                                  ), Digits
                               );     
   if(SL != 0.0 && useSL) sl = NormalizeDouble(Ask - SL*Point, Digits);  // if SL value given by user: Buy S/L, is Ask - supplied SL in points, normalized
   Print("Buy sl = ", sl);
   return(sl);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////ok/////////////////////////////////////////////////////////////////////////////
double SellSL()   {
   double sl;
   if(!useSL) return(0.0);
   //the following sets S/L value to Bid + spread + min. Stop Level
   if(SL == 0.0 && useSL) sl = NormalizeDouble(
                                  Bid + (
                                           MarketInfo(Symbol(), MODE_SPREAD) +
                                           MarketInfo(Symbol(), MODE_STOPLEVEL)
                                         ) * Point
                                  , Digits
                               );
   if(SL != 0.0 && useSL) sl = NormalizeDouble( Bid + SL*Point, Digits );
   Print("Sell sl = ", sl);
   return(sl);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//this function is to prevent multiple trades, later to coordinate with OMS and MoneyMgt. Now to prevent error with 
bool okToOpen()   {   //no hedge rules in US
   int total=OrdersTotal();
   for(int pos=0;pos<total;pos++)   {  //loop over open/pending orders 
      if(OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)==true)   { //might need to catch the posibility that function OrderSelect() will fail
         if(OrderMagicNumber()==magic && OrderSymbol()==Symbol()) return(false); //if open/pending order matches magic of this EA - NOT ok to open another trade
      }
   }
   return(true); //if didn't catch a matching open/pending trade, return okToOpen as true 
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Stats()   {
   if(handle<0)  {                                         //if not openned
      handle=FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE,';');  //create or re-attempt openning
      if(handle<0) Print("Last Error = ", GetLastError()); //if unsuccessfull, print error code
   }
   
   if(handle>0 !prevRead)  {                               //if file successfully openned/created & not prev. read,
     sumread   = FileReadNumber(handle);                   //read what's there
     countread = FileReadNumber(handle);
     prevRead  = true;                                     //flag that the file was read 
     velsum    = sumread;                                  //initialize velsum to sum read from file
     velcount  = countread;                                //initialize velcount to count read from file 
     FileFlush(handle) ;                                   // flush buffer to file between reads/writes
     Print("read from file: ", sumread, ", ", countread);
   }
   
   velsum   = velsum + MathAbs(bidvel);                    //add latest velocity, abs. val. until build separate stats for neg.
   velcount = velcount + 1;                                //increment count
   //add write stats every 15 min.
   return;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StatsWrite()   {
   FileSeek(handle, 0, SEEK_SET);
   FileWrite(handle, DoubleToStr(velsum,8), velcount);
   //FileClose(handle);
   return;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StatsClose()   {
   FileClose(handle);
   return;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void flattenAll()   {  //this function s to flatten all open positions and pending orders
   //Print("hello from flattenAll()");
   double pri;
   int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic /*&& OrderType() < 2*/ ) { //04/06/'12 removed condition for pending orders 
        if(OrderType()==0) pri = Bid; //if buy
        if(OrderType()==1) pri = Ask; //if buy
        OrderClose(OrderTicket(), OrderLots(), pri, 3, CLR_NONE);
     }
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
void flattenPrft()   {
   //Print("hello from flattenPrft()");
   double pri;
   int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() < 2) {
        if(OrderType()==0) pri = Bid; //if buy
        if(OrderType()==1) pri = Ask; //if buy
        if(OrderProfit()>=targetProfit) OrderClose(OrderTicket(), OrderLots(), pri, 3, CLR_NONE);
     }
  }
}
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int Fun_Error(int Error)   {                               // Function of processing errors

   switch(Error)   {                                       // Not crucial errors
   
      case 4: Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                                      // Simple solution
         return(1);                                        // Exit the function
         
      case 135:Alert("Price changed. Trying once again..");
         RefreshRates();                                   // Refresh rates
         return(1);                                        // Exit the function
         
      case 136:Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)                      // Till a new tick
            Sleep(1);                                      // Pause in the loop
         return(1);                                        // Exit the function
         
      case 137:Alert("Broker is busy. Trying once again..");
         Sleep(3000);                                      // Simple solution
         return(1);                                        // Exit the function

      case 146:Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                                       // Simple solution
         return(1);                                        // Exit the function
         
         // Critical errors /////////////////////////////////
      case 2: Alert("Common error.");
         return(0);                                        // Exit the function
      
      case 5: Alert("Old terminal version.");
         Work=false;                                       // Terminate operation
         return(0);                                        // Exit the function

      case 64: Alert("Account blocked.");
         Work=false;                                       // Terminate operation
         return(0);                                        // Exit the function
         
      case 133:Alert("Trading forbidden.");
         return(0);                                        // Exit the function

      case 134:Alert("Not enough money to execute operation.");
         return(0);                                        // Exit the function

      default: Alert("Error occurred: ",Error);            // Other variants
         return(0);                                        // Exit the function
   }                                                       // close switch statement
}                                                          // close Fun_Error() function
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int New_Stop(int Parametr)   {                             // Checking stop levels
   
   int Min_Dist = MarketInfo(Symb, MODE_STOPLEVEL);        // Minimal distance
   
   if (Parametr < Min_Dist)   {                            // (CHANGED TO <) If manually set value is less than min. allowed stop distance,
      Parametr = Min_Dist;                                 // Set stop level to min. allowed instead
      Alert("Increased distance of stop level. New dist. set = ", Parametr);
   }
   
   return(Parametr);                                       // Returning value
}                                                          // close New_Stop() function
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////  Order Management System: OMS() & related functions  /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int OMS()   {
   //local variables
   int Total, Ticket, Tipe, Price, SL, TP, Lot, Magic;
   bool TradingOn = false;
   if(gv == 1.0) TradingOn = true;                         // if this is head EA 'instance' turn on trading function
   //scan market and pending orders
   Symb=Symbol();                                          // Security name from chart window 
   Total=0;                                                // Amount of orders
   
   for(int i=1; i<=OrdersTotal(); i++)   {                 // Loop over market and pending orders
                                                           // if there is the next one; if OrderSelect() worked...
      if(OrderSelect(i-1,SELECT_BY_POS)==true)   {         // else Print("OrderSelect returned the error of ",GetLastError());
         Ticket = OrderTicket();                           // Number of selected order
         Tipe   =OrderType();                               // Type of selected order
         Price =OrderOpenPrice();                          // Price of selected order
         SL    =OrderStopLoss();                           // SL of selected order
         TP    =OrderTakeProfit();                         // TP of selected order
         Lot   =OrderLots();                               // Amount of lots
         Magic =OrderMagicNumber();                        // order magic number
         
         //detect orders that didn't originate from this EA
         if(DoubleToStr(Magic,6) != "762583") Alert("detected order with non-matching magic number!");
         
         //if pending orders found (buy/sell stop/limits)...
         if (OrderType()>1)   {                            // Pending order found...
                                                           /* OP_BUY 0 Buying position. 
                                                              OP_SELL 1 Selling position. 
                                                              OP_BUYLIMIT 2 Buy limit pending position. 
                                                              OP_SELLLIMIT 3 Sell limit pending position. 
                                                              OP_BUYSTOP 4 Buy stop pending position. 
                                                              OP_SELLSTOP 5 Sell stop pending position. 
                                                           */
            Alert("Pending order detected.");

         }//close if(OrderType()...dealing with pending orders
         
         //dealing with market orders
         if(DoubleToStr(Magic,6)=="762583")   {//if order originated from this EA (first 6-digits of magic number match)...
            if(checkIfToExit(Ticket)) { //check if exit conditions exist, 
               if(ExitOrder(Ticket)!=-9) { //exit position
                  Print("Order ", Ticket, " was closed");
               }//close if(ExitOrder())
               else Print("closing of order ", Ticket, " failed! error code:", GetLastError() );
               //need to ad while loop to retry after non-critical errors--see error catching section
            }//close if(checkIfToExit(....
         }//close if(DoubleToStr(Magic()...
      }//close if(OrderSelect(... statement
   }//close for loop over orders 
   
   // check For Entry opportunities
   checkForEntry();
   
}//close OMS()


int ExitOrder(int ticket) { //exits order by ticket number
   double exitPrice;
   OrderSelect(ticket,SELECT_BY_TICKET);
   if(OrderType()==OP_BUY) exitPrice=Bid; //if buy position, to be closed on bid
   if(OrderType()==OP_SELL) exitPrice=Ask;//if sell position, to be closed on ask

   if(!OrderClose(ticket, OrderLots(), exitPrice, slippage, Green)) {
      Print("order close failer for order ", ticket, ", error code: ", GetLastError());
      return(-9);
   }//close if(!OrderClose(...
   else return(ticket);
}//close ExitOrder()


bool checkIfToExit(int ticket) { //this function checks if specific order should be exited
   //exit strategy is matched to entry strategy. entry strategy number is encoded in last 3-digits of order magic number
   // get entry stratgy number (last 3-digits of oder magic number)
   return(checkExit(exitStrategyNumber(ticket), ticket));
}//close checkIfToExit()


bool checkExit(int extSN, int ticket)  {
   switch(extSN) {
      case 101: //market breathing cycle indicator 
      case 118: // trailing stop exit strategy
         //...calculate order trailing stop value, and if market is there, return true
         Print("hi from checkexit()");
      case 100: // minimum allowed TP for scalping
         //...calculate minimum allowed TP value, and if market is there, return true 
         Print("hi from checkexit()");
      case 999: // this is default exit
         //...maybe MA cross
         //if MA cross indicator==1, and OrderType==sell return(true)
         //if....return....
         Print("hi from checkexit()");
   }//close switch
}//close checkExit()


int exitStrategyNumber(int ticket){
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) Alert("OrderSelect() failer for order "+ticket+" last error code is: "+GetLastError());
   int entSN = StrToInteger(StringSubstr(DoubleToStr(OrderMagicNumber(),9),7,3));
   return(entSN);
}//close exitStrategyNumber()


int checkForEntry()  {
   //this needs to check for entry strategy signals for the pair this head instance detects
   //xxxxxxxxxxxxxxxxxxx;
   //it must also receive information from other instances on other pairs
   //compile the list of available opportunities detected by other instances
   //rank the opportunities with respect to expectation for success
   //allocate funds to each opportunity according to rank and risk tolerance
   //send orders to market with proper magic number coding entry strategy , and confirm they got properly executed
   /*
   // Trading criteria
   //set signals
   // if(   iCustom(NULL, 0, "Aharon_Bands_on_Range", 0, 1) > iCustom(NULL, 0, "Aharon_Bands_on_Range", 1, 1)   ) s1 = 1.0; //is range out of BB
   // else s1 = 0.0; 
   //  signal0 = iRSI(Symbol(), Period(), RSIperiod, RSIappliedPrice, 0);
   //   signal1 = iRSI(Symbol(), Period(), RSIperiod, RSIappliedPrice, 1);
        if (signal0>70 && signal1<70)     {                   // if flat and signal up;                           
      //Opn_S=true;  
      //Cls_B=true;                                        // Criterion for opening Buy
   }
   
   if (signal0<30 && signal1>30)     {                  // if flat and signal down;                           
   //   Opn_B=true; 
    //  Cls_B=true;                                         // Criterion for opening Sell
   }
   
   if (  (signal0<=50 && signal1>=50) || (signal0>=50 && signal1<=50)  )     {                  // if flat and signal down;                           
    //  Cls_S=true; 
    //  Cls_B=true;                                         // Criterion for opening Sell
   }
   */
   
   return(0);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////   end of section of code related to OMS()    /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//// AutoHierarchy() manages Head and Subordinate EA instances ////
int AutoHierarchy() {
   gvd = 0.0;
   if(!GlobalVariableCheck("g762583"))  {
      gvd = GlobalVariableSet("g762583",1.0); //230 maarav 147 shtaim F 05062012
   }
   else gv = GlobalVariableGet("g762583"); //global variable
   if(gv == 1.0) gv = 2.0;
   Print("Shalom m-AutoHierarchy(), gv = ", gv);
   return(gv);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()   {
   firstRun = true;
   ObjectsDeleteAll();
   j=0;
   if(!IsExpertEnabled())   Comment("EAs NOT ENABLED...");
   StatsWrite();
   StatsClose();
   return(0);
}

