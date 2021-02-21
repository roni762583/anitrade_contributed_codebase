//+------------------------------------------------------------------+
//|                                       A_i_upOrdnBar2.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// this ind. is for checking if the bar is up or down to be combined with BBonRange and percentoutofbb of price to detect correction
// this version looks for number of consecutive up or dn bars 

#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 White
 
extern int    BarsBack  = 180;  //how far back to calculate

double u, l, sign[], ct[];
static double cnt;
int    limit, i;

int init()  {
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_i_upOrdnBar2" + BarsBack + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "sign");
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, sign);
   
   SetIndexLabel(1, "ct");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, ct);
   
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
   
   for(i=Bars-BarsBack; i>=0; i--) {  
      if(sign[i]==1.0 && sign[i+1]==1.0) cnt = cnt + 1.0;
      if(sign[i]==-1.0 && sign[i+1]==-1.0) cnt = cnt - 1.0;
      if(sign[i]!=sign[i+1]) cnt = 0.0;
      ct[i] = cnt;
   } //close for loop

   return(0);
}

int deinit()  {
   return(0);
}