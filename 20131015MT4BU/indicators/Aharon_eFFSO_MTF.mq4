//      Aharon_eFFSO_MTF.mq4
// this is a multiple TimeFrame version of Aharon_FMSlopeWBBOrdered.mq4
//      Aharon_FF_maxDiff.mq4 copyright
// this plots the difference between FIRMA_FULL on Highs and FIRMA_FULL on Lows
//+------------------------------------------------------------------+
//|                                             FIRMA_MA_MA_Full.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           Aharon_FIRMA_MA_MA.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Blue
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
//default values correspond to tested values

extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern double ThldDecimal = 1.0;
extern int    TF1         = 5;
extern int    TF2         = 5;
extern int    TF3         = 15;

//---- buffers
double FFSO_TF1[];   //FIRMA SLOPE EST. OVER BBands in TF1
double FFSO_TF2[];   //FIRMA SLOPE EST. OVER BBands in TF2
double FFSO_TF3[];   //FIRMA SLOPE EST. OVER BBands in TF3
double Signal[];     //result
//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(4);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "eFFSO_MTF(" + BandsDeviations + ", " + BandsPeriod + ", " + ThldDecimal + ", " + TF1 + ", " + TF2 + ", " + TF3 + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"FFSO_TF1");
   SetIndexLabel(1,"FFSO_TF2");
   SetIndexLabel(2,"FFSO_TF3");
   SetIndexLabel(3,"Signal");
                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   
   SetIndexBuffer(0,FFSO_TF1);
   SetIndexBuffer(1,FFSO_TF2);
   SetIndexBuffer(2,FFSO_TF3);
   SetIndexBuffer(3,Signal);
   
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
                                                             // Set values
   for(i=0; i<limit; i++)  {
      FFSO_TF1[i]= iCustom(NULL, TF1, "Aharon_FMSlopeWBBOrdered", 
                           BandsDeviations, BandsPeriod, ThldDecimal,    //parameters as listed below
                           0, i);                                        //mode 0 is signal 1, -1, 0             
                             /*
                             double BandsDeviations=2.0;
                             int    BandsPeriod=20;
                             double ThldDecimal = 1.0;                           //Threshold multiple above/below bands
                             */
   }
   for(i=0; i<limit; i++)  {
      FFSO_TF2[i]= iCustom(NULL, TF2, "Aharon_FMSlopeWBBOrdered", 
                           BandsDeviations, BandsPeriod, ThldDecimal,    //parameters as listed above
                           0, i);                                        //mode 0 is signal 1, -1, 0
   }
   
   for(i=0; i<limit; i++)  {
      FFSO_TF3[i]= iCustom(NULL, TF3, "Aharon_FMSlopeWBBOrdered", 
                           BandsDeviations, BandsPeriod, ThldDecimal,    //parameters as listed above
                           0, i);                                        //mode 0 is signal 1, -1, 0
   }
   
   for(i=0; i<limit; i++)  {
      if( FFSO_TF1[i] == 1.0  &&  FFSO_TF2[i] == 1.0  &&  FFSO_TF3[i] == 1.0 ) Signal[i] = 1.0;
         else if( FFSO_TF1[i] == -1.0  &&  FFSO_TF2[i] == -1.0  &&  FFSO_TF3[i] == -1.0 ) Signal[i] = -1.0;
            else Signal[i] = 0.0;
   }      
   return(0);
}