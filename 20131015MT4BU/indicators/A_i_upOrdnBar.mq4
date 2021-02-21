//+------------------------------------------------------------------+
//|                                       A_i_upOrdnBar.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// this ind. is for checking if the bar is up or down to be combined with BBonRange and percentoutofbb of price to detect correction

#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue
 
extern int    BarsBack  = 180;  //how far back to calculate

double u, l, sign[];

int    limit, i;

int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_upOrdnBar" + BarsBack + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "sign");
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, sign);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=Bars-BarsBack; i>=0; i--) {  
      if(Open[i]<Close[i]) sign[i] = 1.0;
      if(Open[i]>Close[i]) sign[i] = -1.0;
   } //close for loop

   return(0);
}

int deinit()  {
   return(0);
}