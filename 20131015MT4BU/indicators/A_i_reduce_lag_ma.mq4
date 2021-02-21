//+------------------------------------------------------------------+
//|                                            A_i_reduce_lag_ma.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//to compare moving avg methods, sma, exp, and reduced lag (2Xnew value - prev. value)
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

//---- external parameters
extern double malen=4;


//---- buffers
double ma[];
double rlma[];
double ema[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="Reduce_Lag_MA("+malen+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ma-red");
   SetIndexLabel(1,"rlma-blue");
   SetIndexLabel(2,"ema-green");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ma);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,rlma);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ema);

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
      ma[i]=iMA(NULL, 0, malen, 0, MODE_SMA, MODE_CLOSE, i);
   }
   
   for(i=0; i<limit; i++)  {
      rlma[i]=2*ma[i]-ma[i+1];
   }
   
   for(i=0; i<limit; i++)  {
      ema[i]=iMA(NULL, 0, malen, 0, MODE_EMA, MODE_CLOSE, i);
   }

   return(0);
}
//+------------------------------------------------------------------+