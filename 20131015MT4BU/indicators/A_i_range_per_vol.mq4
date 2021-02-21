//+------------------------------------------------------------------+
//|                                            A_i_range_per_vol.mq4 |
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
 
double rpv[];

int    limit, i;
double r, v;


int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_range_per_vol";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "rpv");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, rpv);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   
   for(i=0; i<limit; i++)  {
      
      r = MathMax(1,(High[i] - Low[i])/Point);
      v = MathMax(Volume[i], 1);
      rpv[i] =  r/v;
      //MathMax(si[i], 0.0);//asi[i+1] + si[i];
   }

   return(0);
}

int deinit()  {
   return(0);
}