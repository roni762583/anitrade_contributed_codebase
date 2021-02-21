//+------------------------------------------------------------------+
//|                                         Aharon_EA_FIRMA_MOM1.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

//This EA is intended to initialy trigger a alert/signal based on the FIRMA_MA_MA_Full_MOM family of indicators  
//It is intended to later incorporate comment functionality of the Aharon_Simple_EA2
//And the while cycling of continuous time window of Aharon_Simple_EA3 - still in development
//Later it i to be re-written in a clean way to incorporate all above changes

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
extern int    TF1 = 0;       //zero means current chart time frame
extern int    Period1 = 4;
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

extern double pa = 1.0, pb = 1.0; //percents above and below BB to trigger flags: MomAbvUBB, MomBlwLBB

extern double fsa = 1.0;   //fsa, fsb, & fsc are weights for FIRMAslope() calculation
extern double fsb = 1.0;   //fsa is weight for diff on last two bars, fsb the weight on diff between 3rd and 2nd bars 
extern double fsc = 1.0;   //fsc is weight for diff between 1st and 3rd bars 

double fs = 0.0;     //FIRMAslope variable
bool MomAbvUBB, MomBlwLBB;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()  {
//----
   start();  //can wait for tick forever...
//----
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()  {

   fs = FIRMAslope(fsa, fsb, fsc);
   
   
   //this will set MomAbvUBB flag if Momentum line is above UBB ///////////////////////////////////////////////////////////////////////////////
   if(iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     3,                              //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     0)                              //index; zero is last bar
      >
      iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     4,                              //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     0) * pa                         //index; zero is last bar
   )   {
      MomAbvUBB = true;
   } else MomAbvUBB = false;
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //this will set MomBlwLBB flag if Momentum line is below LBB ///////////////////////////////////////////////////////////////////////////////
   if(iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     3,                              //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     0)                              //index; zero is last bar
      <
      iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     5,                              //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     0)                              //index; zero is last bar
   )   {
      MomBlwLBB = true;
   } else MomBlwLBB = false;
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   Alert("MomAbvUBB is  " + MomAbvUBB + "\n" +
         "MomBlwLBB is  " + MomBlwLBB + "\n" +
         "fs = " + fs); 
//----
   return(0);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
//----
   
//----
   return(0);
}

////////////////////////////FIRMAslope() defined below ////////////////////////////////////////////////////////////////////////////////////////
double FIRMAslope(double fsa, double fsb, double fsc, int firstbar = 0, int secondbar = 1, int thirdbar = 2)  {
double d01 = 0.0, d12 = 0.0, d02 = 0.0;

   //d01 delta betweeen last two bars (firstbar and secondbar)
   d01 = iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     firstbar)                       //index; zero is last bar
        -
         iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     secondbar);  
   //d12 delta between prev.-to-last bar, and two-bars ago (secondbar and thirdbar)
   d12 = iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     secondbar)                      //index; zero is last bar
        -
         iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     thirdbar);
   d02 = d01 + d12;   //delta between last bar, and two-bars-ago (firstbar and thirdbar)
   
   fs = ((fsa*d01 + fsb*d12 + fsc*d02)/(fsa + fsb + fsc)) * MathPow(10,Digits);  //weighed average to quantify slope over last three bars 
   
      return(fs);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

