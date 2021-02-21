//+------------------------------------------------------------------+
//|                                       A_i_SMApaddedATR.mq4       |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// this ind. is for checking if the bar is up or down to be combined with BBonRange and percentoutofbb of price to detect correction
// this version looks for number of consecutive up or dn bars 

#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 White
 
extern int    BarsBack  = 180,  //how far back to calculate
              atrPeriod = 14;   //
extern double atrFraction = 0.5;

double u, l, sma, atr, upr[], lwr[];
static double cnt;
int    limit, i;

int init()  {
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_i_SMApaddedATR";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "upr");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, upr);
   
   SetIndexLabel(1, "lwr");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, lwr);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=Bars-BarsBack; i>=0; i--) {  
      sma = iMA(NULL, 0, 15, 0, 0, 0, i);
      atr = iATR(NULL, 0, atrPeriod, i);
      upr[i] = sma + (atr * atrFraction);
      lwr[i] = sma - (atr * atrFraction);
   } //close for loop
   

   return(0);
}

int deinit()  {
   return(0);
}