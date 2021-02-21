//+------------------------------------------------------------------+
//|                                       Aharon_BB_on_7barslope.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                             BB_on_7Bar_Slope_Zscore.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_ATR.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

//---- external parameters
extern int    ma_period = 20;


//---- buffers
double D[];
double ZS[];

int init()  {
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="BB_on_7barslope_Zscore("+ma_period+")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"D-Red");
   SetIndexLabel(1,"ZS-Green");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ZS);

   return(0);
}


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
      D[i]=iCustom(NULL, 0, "Aharon_7_Bar_Avg_Slope_Pips_per_Min", 0, i);
   }
   
   for(i=0; i<limit; i++)  {
      ZS[i] = (D[i]- iMAOnArray(D,  0, ma_period, 0, MODE_SMA, 0))/iStdDevOnArray(D, 0,ma_period, 0, MODE_SMA, 0) ;
   }

   return(0);
}

int deinit()  {
   return(0);
}