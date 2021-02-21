//+------------------------------------------------------------------+
//|                                            A_i_range_thshld.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                  A_i_WWJ_ASI.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue

extern int thld = 20; //in pips

 
double r[];

int    limit, i;
double v;


int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_range_thshld";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "r");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, r);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   
   for(i=0; i<limit; i++)  {
      //if(MathMax(1,(High[i] - Low[i])/Point)>=thld) r[i] =  MathMax(1,(High[i] - Low[i])/Point);
      if(MathAbs(Close[i]-Open[i])/Point >= thld) r[i] =  (Close[i] - Open[i])/Point;
         else r[i]=0;
   }

   return(0);
}

int deinit()  {
   return(0);
}