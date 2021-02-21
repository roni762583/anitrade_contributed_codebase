//+------------------------------------------------------------------+
//|                             Aharon_FIRMA_MA_MA_Momentum_W_BB.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Purple
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Blue



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
extern int    TF1 = 0;
extern int    Period1 = 4;
extern int    Taps1   = 21;  //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 7;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 7;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MomLength = 1; //length for momentum
extern int    BBPeriod = 14;

extern int    BBDeviations = 2;
extern int    BBShift = 0;


//---- buffers
double FIRMA[];
double MA1[];
double MA2[];
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
   short_name = "FIRMA_MA_MA_Mom_BB(" + Period1 + ", " + MA1Period + ", " + MA2Period + ", " + 
                MomLength + ", " + BBPeriod + ", " + BBDeviations + ", " + BBShift + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,StringConcatenate("FIRMA", TF1, Period1, Taps1, Window1));
   
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
   
   

                                                            // Set values
   
   for(i=0; i<limit; i++)  {
   
      FIRMA[i]= iCustom(NULL, TF1, "Aharon_FIRMA_ARMA", Period1, Taps1, Window1,   0, i);
     
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
         
   return(0);

}


