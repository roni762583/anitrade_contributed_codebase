// AiMAsCompare.mq4
#property copyright "Copyright © 2010, Aharon"

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gold
#property indicator_color4 Green

extern int    Len  = 7;
extern int    ap   = 0;
extern int    Shft = 0;

double sma[];
double ema[];
double smma[];
double lwma[];

int init()  {
   IndicatorBuffers(4);
   string short_name;
   short_name = "AiMAsCompare.mq4(" + Len + ", " + ap + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "sma");
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, sma);
   
   SetIndexLabel(1, "ema");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ema);
   
   SetIndexLabel(2, "ssma");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,smma);
   
   SetIndexLabel(3, "lwma");
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,lwma);
   
   return(0);
}

int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      sma[i] = iMA(NULL, 0, Len, Shft, MODE_SMA, ap, i);
      ema[i] = iMA(NULL, 0, Len, Shft, MODE_EMA, ap, i);
      smma[i] = iMA(NULL, 0, Len, Shft, MODE_SMMA, ap, i);
      lwma[i] = iMA(NULL, 0, Len, Shft, MODE_LWMA, ap, i);
   }
   /*
   for(i=0; i<limit; i++)  {
      p0 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i);    //avgs represent prices
      p1 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i+1);
      p01 = (p0 - p1) * MathPow(10,Digits);
      eFslope_H[i] = p01/t;
   }*/                
   return(0);
}

int deinit()  {
   return(0);
}