//+------------------------------------------------------------------+
//|                                           Aharon_FIRMA_Slope.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                        Aharon_Bands_on_BW.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_ATR.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern int    SigmaPeriod = 5;

//---- buffers
double D[], R[];
double BBu[];
double BBl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);    //additional buffer for calc.
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="BB_on_Sigma("+SigmaPeriod+", "+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Sigma");
   SetIndexLabel(1,"Upper");
   SetIndexLabel(2,"Lower");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set values
   
   for(i=0; i<limit; i++)  {
   //Print("hi, lo, hi-lo=",High[i], ",", Low[i], ",", High[i] - Low[i]); 
   //
      R[i]= High[i] - Low[i];
   
   //if(i==19) break;   
   }
   Print("R5=",R[5]);
   
   for(i=0; i<limit; i++)  {
      D[i]= iStdDev(NULL, 0, 20, 0, MODE_SMA,PRICE_CLOSE,0); //D[i]= High[i] - Low[i]; //iMAOnArray(R, 0, RangePeriod, 0, MODE_SMA, i);
   //Print("ii=",i);  
   //if(i==12) break;
   }
   
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+