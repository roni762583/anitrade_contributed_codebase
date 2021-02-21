//+------------------------------------------------------------------+
//|                                     Aharon_FMMMFMWBB_COMPLEX.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// This indicator to provide multiple TF mom. conf. w/ ordered ma for filterint trades, and another ordered ma for exiting 12/17/09
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
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 LightGreen
#property indicator_color5 White
#property indicator_color6 Blue
#property indicator_color7 LightBlue
#property indicator_color8 Gray

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
extern int    TF0 = 0;                                     //Current chart Time Frame 
extern int    TF1 = PERIOD_M5;                             //1st Time Frame 
extern int    TF2 = PERIOD_M15;                            //2nd Time Frame 

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

int UpCounter = 0;   //to count number of up overshoots of UBB
int DnCounter = 0;   //to count number of Down overshoots of LBB
int Tally = 0;       //to tally ups/dns
string s = ""; //for message 
bool upalertflag = false, downalertflag = false;


//---- buffers
double TF1FMMMFOfilter[];                                   // FIRMA[]; FIRMAMAMAFULLORDERED for filtering entries
double TF1FMMMFOexit[];                                     // MA1[];   FIRMAMAMAFULLORDERED for exit signal
double TF1FMMMFWBBO[];                                      // MA2[];   FIRMAMAMAFULLwBBORDERED for enty signal
double TF1SLOPE2THD[]                                       // IF EST. SLOPE 
double Mom[];
double UBB[];
double LBB[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(6);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "FMMMFMWBB_COMPLEX(" + Period1 + ", " + MA1Period + ", " + MA2Period + ", " + 
                MomLength + ", " + BBPeriod + ", " + BBDeviations + ", " + BBShift + ")see exp. CODE";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,StringConcatenate("FIRMA", TF0, Period1, Taps1, Window1));
   
   SetIndexLabel(1, StringConcatenate("MA1(", MA1Period,")"));
   SetIndexLabel(2, StringConcatenate("MA2(", MA2Period,")"));
   SetIndexLabel(3, StringConcatenate("Momentum (", MomLength, ")"));
   SetIndexLabel(4, "UBB");
   SetIndexLabel(5, "LBB");

                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FIRMA);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA1);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MA2);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Mom);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,UBB);
   
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5, LBB);

   //PlaySound("p2bhatzlacha.wav");
   
   return(0);
}



//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()  {

                                //----
   
                                //----
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
   
   //Comment("test Comment...");                              // test Comment() on indicator    

                                                            // Set values
   
   for(i=0; i<limit; i++)  {
   
      FIRMA[i]= iCustom(NULL, TF0, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2, i);
     
   }
    
   for(i=0; i<limit; i++)  {
   
      MA1[i]= iMAOnArray(FIRMA, 0, MA1Period, MA1shift, MA1method , i);



     
   } 
         
   for(i=0; i<limit; i++)  {
   
      MA2[i]= iMAOnArray(MA1, 0, MA2Period, MA2shift, MA2method , i);
     
   }      
   
   
   for(i=0; i<limit; i++)  {
   
      Mom[i]= (iMomentumOnArray(MA2, 0, MomLength, i) - 100.0)*10000;
     
   }
   
   for(i=0; i<limit; i++)  {
   
      UBB[i]= iBandsOnArray(Mom, 0, BBPeriod, BBDeviations, BBShift, MODE_UPPER, i);
      LBB[i]= iBandsOnArray(Mom, 0, BBPeriod, BBDeviations, BBShift, MODE_LOWER, i);
     
   }
    
   for(i=limit-1; i>=0; i--)  {                            //revese order of indeces
      if(i == 0 && Mom[i]<UBB[i] && Mom[i]>LBB[i])   {     //this resets alert flags if signal is between bands on current bar
         upalertflag = false;
         downalertflag = false;
      }
      
      if(Mom[i]>UBB[i] && Mom[i+1]<=UBB[i+1])   {          //if Mom overshot UBB since last bar ...
         if(i == 0 && upalertflag == false)   {            //if current bar AND is new alert of signal...
            //Alert("Mom overshot! BUY!"+"  \n"+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"  Local machine time");
            //PlaySound("p2kne.wav");
            upalertflag = true;                            //set alert flag true 
            downalertflag = false;                         //reset opposite signal alertt flag
         }
         UpCounter++;
         Tally++;
         s = "last was overshoot on: " + TimeToStr(Time[i],TIME_DATE|TIME_MINUTES) + ", " + (TimeCurrent()-Time[i])/60 + " minutes ago";
      }
      if(Mom[i]<LBB[i] && Mom[i+1]>=LBB[i+1])   {          //if Mom overshot LBB since last bar ...
         if(i == 0 && downalertflag == false)   {          //if current bar AND is new alert of signal...
            //Alert("Mom undershot! SELL!"+"  \n"+TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES)+"  Local machine time");
            //PlaySound("p2mchor.wav");
            upalertflag = false;                           //set alert flag true
            downalertflag = true;                          //reset opposite signal alertt flag
         }
         DnCounter++;
         Tally--;
         s = "last was undershoot on: " + TimeToStr(Time[i],TIME_DATE|TIME_MINUTES) + ", " + (TimeCurrent()-Time[i])/60 + " minutes ago";
      }     
   } 
   
   double d = 0.0, u = 0.0, days = 0.0;
   days = (TimeCurrent()-Time[Bars-1])/(60*60*24);
   u = UpCounter/days;                                     //((TimeCurrent()-Time[Bars-1])/(60*60*24));
   d = DnCounter/days;                                     //((TimeCurrent()-Time[Bars-1])/(60*60*24));
   
   Print("Up = ", UpCounter, ", Dn = ", DnCounter, ", since: ", 
         TimeToStr(Time[Bars-1],TIME_DATE), ", ~= ", 
         days, " days.", " roughly ", u, " overshoots/day, and ", d, " undershoots/day."  );
   
   Print(s, ".  Tally = ", Tally , ",  upalertflag = ", upalertflag, ",  downalertflag = ", downalertflag);
   return(0);

}