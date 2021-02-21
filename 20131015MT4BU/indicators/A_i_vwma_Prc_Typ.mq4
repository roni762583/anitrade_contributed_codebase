// A_i_vwma_Prc_Typ.mq4
#property copyright "Copyright © 2010, Aharon"

#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 Blue

extern int    Len  = 15;

double t_vwma[];

int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_vwma_Prc_Typ(" + Len + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "t_vwma");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, t_vwma);
   
   return(0);
}

int start()  {
   int limit, i, j;
   double v, vc;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      vc = 0.0;
      v  = 0.0;
      for(j=0; j< Len; j++)   {
         vc = vc + MathMax(Volume[i+j], 1)*((Close[i+j]+Open[i+j]+High[i+j]+Low[i+j])/4);
         v  = v  + MathMax(Volume[i+j], 1);
      }
      t_vwma[i] = vc/v;
   }
   return(0);
}

int deinit()  {
   return(0);
}