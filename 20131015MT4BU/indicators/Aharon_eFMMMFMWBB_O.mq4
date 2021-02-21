//     Aharon_eFMMMFMWBB_O.mq4
//+------------------------------------------------------------------+
//|                                     Aharon_FMMMFMWBB_COUNTER.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// The idea is to count how many overshoots of the bands occur over the time series and display it for stats.
//+------------------------------------------------------------------+
//|                        Aharon_FIRMA_MA_MA_Full_Momentum_W_BB.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                             Aharon_FIRMA_MA_MA_Momentum_W_BB.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue


//---- external parameters
/*///////////////////              Time Frame Options  /////////////////////////
PERIOD_M1 1 minute. 
PERIOD_M5 5 5 minutes. 
PERIOD_M15 15 15 minutes. 
PERIOD_M30 30 30 minutes. 
PERIOD_H1 60 1 hour. 
PERIOD_H4 240 4 hour. 
PERIOD_D1 1440 Daily. 
PERIOD_W1 10080 Weekly. 
PERIOD_MN1 43200 Monthly. 
0 (zero) 0 Timeframe  
//////////////////////////////////////////////////////////////////////////////*/
//Initial values correspond to tested values
extern int    TF1 = 0;
extern int    Period1 = 20;
extern int    Taps1   = 21;  //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 3;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 3;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MomLength = 1; //length for momentum
extern int    BBPeriod = 14;

extern int    BBDeviations = 2;
extern int    BBShift = 0;

double mom, ubb, lbb;

//---- buffers
double S[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(1);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "eFMMMFMWBB_O(" + Period1 + ", " + MA1Period + ", " + MA2Period + ", " + 
                MomLength + ", " + BBPeriod + ", " + BBDeviations + ", " + BBShift + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Signal");
   
                                  //---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,S);

   return(0);
}



//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}



//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+

int start()   {

   int limit, i;
   int counted_bars=IndicatorCounted();
                                                            //---- check for possible errors
   if(counted_bars<0) return(-1);
                                                            //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
      
   for(i=0; i<limit; i++)  {
       mom = iCustom(NULL, TF1, "Aharon_FMMMFMWBB_COUNTER",
                     TF1,
                     Period1,
                     Taps1,
                     Window1,
                     MA1Period,
                     MA1shift,
                     MA1method,
                     MA2Period,
                     MA2shift,
                     MA2method,
                     MomLength,
                     BBPeriod,
                     BBDeviations,
                     BBShift,
                     3,             //mode 3 is mom
                     i);

       ubb =  iCustom(NULL, TF1, "Aharon_FMMMFMWBB_COUNTER",
                     TF1,
                     Period1,
                     Taps1,
                     Window1,
                     MA1Period,
                     MA1shift,
                     MA1method,
                     MA2Period,
                     MA2shift,
                     MA2method,
                     MomLength,
                     BBPeriod,
                     BBDeviations,
                     BBShift,
                     4,                   //mode 4 is UBB
                     i);
                     
       lbb =  iCustom(NULL, TF1, "Aharon_FMMMFMWBB_COUNTER",
                     TF1,
                     Period1,
                     Taps1,
                     Window1,
                     MA1Period,
                     MA1shift,
                     MA1method,
                     MA2Period,
                     MA2shift,
                     MA2method,
                     MomLength,
                     BBPeriod,
                     BBDeviations,
                     BBShift,
                     5,                   //mode 5 is LBB
                     i);
                     
       S[i] = 0.0;                        //initially, set S[i] to zero
       if( mom > ubb ) S[i] = 1.0;        //however, in the case mom is over UBB, set S[i] to 1.0
       if( mom < lbb ) S[i] = -1.0;       //or, if mom is under LBB , set S[i] to -1.0                      
   }
   
   return(0);
}