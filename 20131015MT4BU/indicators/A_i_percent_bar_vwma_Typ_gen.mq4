//+------------------------------------------------------------------+
//|                                 A_i_percent_bar_vwma_Typ_gen.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue

double percent_vwma_g[];

int limit, i, Len, Shft;

int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_percent_bar_vwma_Typ_gen(" + Len + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "percent_vwma_g");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, percent_vwma_g);

   Len = Period();
   
   return(0);
}

int start()  {
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
         
   double den;
   for(i=0; i<limit; i++)  {
      if((High[i]-Low[i]) == 0) den = 1; 
         else den = (High[i]-Low[i]);
      percent_vwma_g[i] = (iCustom(NULL, 0, "A_i_vwma_Prc_Typ_gen", 0, i)-Low[i])/den * 100;
   }

   return(0);
}

int deinit()  {
   return(0);
}