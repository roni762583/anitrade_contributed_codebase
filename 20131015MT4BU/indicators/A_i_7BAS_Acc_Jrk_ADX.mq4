//+------------------------------------------------------------------+
//|                                         A_i_7BAS_Acc_Jrk_ADX.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
/*
while both:
(a) ADX(14) line is above its' own SMA(200), and
(b) AllSameSign indicator is not equal zero,

Initiate and Stay in a trade, in the direction of the AllSameSign ind. (i.e. pos. or neg.)

try in the 30min. time frame
*/ 

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- external parameters
extern double BandsDeviations=0.0;
extern int    BandsPeriod=200;

//---- buffers
double Signal[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_7BAS_Acc_Jrk_ADX("+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Signal");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Signal);

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
      if(iCustom(NULL, 0, "A_i_BB_ADX", BandsDeviations, BandsPeriod,  0, i) <          //ADX line
         iCustom(NULL, 0, "A_i_BB_ADX", BandsDeviations, BandsPeriod,  1, i)   &&      //larger than its' SMA(200)
         iCustom(NULL, 0, "A_i_BB7BASlp_Acc", BandsDeviations, BandsPeriod, 5, i
        
        )
      Signal[i]=
   }
   

   return(0);
}
//+------------------------------------------------------------------+