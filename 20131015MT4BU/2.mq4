// 2.mq4
// Aharon
#property copyright    "Copyright 2013, Roni"
#property link         "http://www.roni.net"

#define magic            762583

       bool    run            = true;
       bool    master         = false;  //indicates position in instance hierarchy

       double   gv             = -9.0;   //contains value from gv...to be used as communicae between instances

datetime hirearchyTime = 0; //holds time gv was set (gv is saved for two weeks in terminal)
///////////////////////////////////
//user input variables
extern int barsBack = 0;
//extern int       magic             = 762583;               //this is magic number for this EA, a specific entery strategy number to be appended to it (3-digits)
extern double    tmWindow          = 15000.0;              //time[msec.] 60000
extern double    posHighVelThshld  =  15.00;       
extern double    negHighVelThshld  = -15.00;       
extern double    lots              = 0.01;
extern double    useSL             = true;
extern double    useTP             = true;
extern double    SL                = 0.0;
extern double    TP                = 0.0;
extern double    nMAbidVelSm       = 7;//was 21                   //period of MA on bidvelsumavg
extern int       slippage          = 3;
extern int       bAMAn             = 10;                   //is n for bids AMA calc
extern int       nmin              = 2;                    //is minimum averaging period of AMA
extern int       nmax              = 30;  //was 30          //is maximum averaging period of AMA
extern double    SMAoAMAperiod     = 5.0;                  //period of SMA on AMA bids
extern int       VIDYA_N           = 1;                    //VIDYA period 
extern int       VIDYA_m           = 25;                   //Efficiency Ratio Period
extern double    SMAoVIDYAperiod   = 10.0;                 //period for SMA on VIDYA of Bids
extern double    SMAoVIDYAperiod2  = 20.0;                 //period for SMA on VIDYA of Bids
extern bool      autoTrade         = false;                //whether to turn on automatic trading
extern bool      emailAlerts       = false;                //whether to email alerts
extern bool      useTimeWindow     = true;                 //added 08/13/12 to allow shutting off this feature for testing other parts
extern bool      drawRS            = false;                 //whether to draw support and resistance level lines on chart 
extern bool      drawDirectionMark = true;                //whether to draw marker at location of direction change 04/09/'13
extern bool      printCycleTime    = false;                //whether to print program cycle time in log - use for testing
extern bool      prntTmWndwErr     = false;                //whether to print estimated error in time window calculations
//static variables
static datetime  LatchTime,
                 gvd;                         //this is to hold datetime of setting of Global Variable for AutoHierarchy()
static int       j                 = 0;
static bool      firstRun          = true;
static string    s;                           //used to hold strings for Object names and comment construction
static double    z                 = 0.0,
                 zp                = 0.0;
static int       handle = -2;                 //handle for file reading/writing, -2 is initialized value
static bool      openned = false;             //flag to indicate if file already openned this session
static bool      prevRead = false;            //to flag if preveously read, then don't read again
static string    filename;                    // file naming: broker,pair
static double    velsum, velcount;            //vars to hold vel. sum and count for stats funct. 
static double    sumread           = 0.0;     //to hold vel. sum read from file 
static double    countread         = 0.0;     //to hold vel. count read from file 
static double    bidvel            = 0.0;     //to hold bid velocity
static double    bidvelsum         = 0.0;     //to hold bid velocity sum
static double    bidvelsumavg      = 0.0;     //bidvelsumavg
static double    bidvel2           = 0.0;     //02/28/'12 to experiment with while constructing
static double    prevBidVelSumAvg  = 0.0;     //stores previous value of bidvelsumavg for MA calculation
static double    dirBidVelSum      = 0.0;     //sum of bid velocities during directional arrow
static double    bDirection        = 0.0;     //used in bids AMA calculation
static double    bAMAv             = 0.0;     //bids AMA volatility in calculation
static double    bER               = 0.0;     //efficiency ratio in bids AMA calculation
static double    bSSC              = 0.0;     //used in bids AMA calculation
static double    bC                = 0.0;     //"""
static double    bRes              = 0.0;     //"""
static double    prevbAMA          = 0.0;     //stores prev. value in bids AMA calculation
static double    SMAoAMA           = 0.0;     //SMA on AMA bids

static double    VIDYA_d;                     //used in VIDYA calculations
static double    VIDYA_v;                     //used in VIDYA calculations
static double    VIDYA_y;                     //used in VIDYA calculations
static double    VIDYA_result      = 0.0;     //used in VIDYA calculations
static double    prevVMA;                     //used in VIDYA calculations
static double    SMAoVIDYAbids     = 0.0;     //SMA of VIDYA of Bids
static double    SMAoVIDYAbids2    = 0.0;     //2nd SMA of VIDYA of Bids
static int       index;                       //a var. to hold index of array in time window calculations
static bool      newRate           = false;   //flag to indicate when new rate is received
static bool      newBid            = false;   //indicates new bid value
static bool      newAsk            = false;   //indicates new ask value
static bool      posHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      negHighVelTrig    = false;   //flag to prevent multiple triggers from same signal
static bool      primed            = false;   //flag to prevent operations without sufficient working time of length time window 
static bool      bidBufferPrimed   = false;   //flag to limit based on if sufficient bids came through to averages, etc.
static datetime  timeOfLastBar;               //required for isNewBar() 04/07/'13
static double    lastBid, lastAsk;            //arrays to hold last rates, 
static double    lastTs;                      //last time stamp
static int       programStarted;              //to store program start time in millisec.
static int       cts;                         //cycle time stamp, for monitoring pgm. cycle time 
static int       b                 = 0;       //temp var.
static int       dct = 0;                     //directional count: counts pos. & neg. velocities
static int       bidBufferCounter   = 0;      //how many new Bids went into calculation
static int       direction         = 0;       //stores direction based on Bid Vel. Sum vs. its' Avg.
static int       prevDirection     = -9;      //stores previous state of direction var.
static int       pNonZeroDirect    = 0;       //stores prev. non-zero direction to detect change from up 2 dn, and vise versa
static double    firstbid; 
                 
       double    a;                           //used with VIDYA calculation 04/08/'13
       double    timeStamps[6000];            //to hold last 6000 time-stamps (10 msec. per cycle, at 60 sec. time window)
       double    bids[6000];                  //to hold last 6000 bids
       double    asks[6000];                  //to hold last 6000 asks        
       double    bidVel[100];                 //to hold last 100 Bid velocities
       double    z15levels[15], z60levels[15], z1440levels[15], z10080levels[15], z43200levels[15]; //levels are zigzag prices
       double    levels[100];                 //02/28/'12 to get levels from all level arrays 
       double    VMA[100];                    //array for VIDYA 04/09/2013
       double    bAMA[1000];                  //for bids AMA
       
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
///////////////////////////////////


int init()  {
      //LatchTime = TimeCurrent();
   //int ah = AutoHierarchy();
   //if(ah==1.0) 
   
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





int start()  {
   preliminary();
   mainLoop();
   return(0);
}


//This is where preliminary setup and calculations are done
void preliminary()  {
   autoHirearchy();
   initComment();
}


//This is where everything happens
void mainLoop()   {
   while(run){
      break;
   }
}



void autoHirearchy()  {
   if(!GlobalVariableCheck("ah762583"))  {
      hirearchyTime = GlobalVariableSet("ah762583", 1);
      if(hirearchyTime!=0) master = true; //master is flag for master instance
      else log("error in GlobalVariableSet()");
      return;
   }
   gv = GlobalVariableGet("ah762583");
   if(gv==0) log("error is GlobalVariableGet");
   else  {
      master = false; //if gv exists, master is already in position
   }
   return;
   //in deinit() delete gv
}


void initComment()   {
   Comment("Initial/perliminary Comments...calling autoHierarchy()");
}


void log(string msg)  {
   int handle;
   handle=FileOpen("log762583",FILE_BIN|FILE_READ|FILE_WRITE);
   if(handle<1)    {
     Print("File my_data.dat not found, the last error is ", GetLastError());
     return;
   }
   if(handle>0)    {
     FileSeek(handle, 0, SEEK_END);
     FileWriteString(handle, msg, 32);
     FileClose(handle);
     handle=0;
   }
}//close log()

int deinit()  {
   if(GlobalVariableCheck("ah762583") && master) GlobalVariableDel("ah762583"); //master to delete gv on exit
   return(0);
}