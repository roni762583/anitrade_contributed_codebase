// A_i_vwma_Prc_Typ_gen.mq4
#property copyright "Copyright © 2010, Aharon"

#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 Blue

double t_vwma_g[];

int limit, i, Len, Shft;

int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_vwma_Prc_Typ_gen(" + Len + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "t_vwma_g");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, t_vwma_g);

   Len = Period();
   
   return(0);
}

int start()  {
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
         
   for(i=0; i<limit; i++)  {
      Shft = iBarShift(NULL, 1, (Time[i] + (Len-1)*60), false);
      if(i==0) Print("Time[i] = ", TimeToStr(Time[i]), ",   time at corresponding 1M = ", TimeToStr((Time[i] + (Len-1)*60)), ",  whose index is ", Shft);
      t_vwma_g[i] = iCustom(NULL, 1, "A_i_vwma_Prc_Typ", Len, 0, Shft);
   }

   return(0);
}

int deinit()  {
   return(0);
}