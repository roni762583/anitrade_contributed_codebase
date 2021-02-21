//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_ATRoverSD.mq4 |
//|                      
//|                                       
//+------------------------------------------------------------------+
#property copyright "Copyright © 20013, Aharon"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern int    ATRperiod = 1;
extern int    SDperiod = 20;

//---- buffers
double D[];
double BBu[];
double BBl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="Bands_on_ATRoverSD("+ATRperiod+", "+SDperiod+", "+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ATR/SD");
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
      D[i]= iATR(Symbol(),0,ATRperiod,i)/MathMax(iStdDev(Symbol(),0,SDperiod,0,MODE_SMA,PRICE_CLOSE,i), Point/1000.0);
   }
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+