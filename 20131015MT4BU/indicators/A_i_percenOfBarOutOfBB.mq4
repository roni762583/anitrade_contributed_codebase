//+------------------------------------------------------------------+
//|                                       A_i_percenOfBarOutOfBB.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// this ind. is for percentage of price bar range that is outside bolinger bands
// to be combined with BB on range indicator, that if range exceeds B Bands AND 
// price bar exceeds bands of threshold percentage - then it is likely for correction move in small timeframe(5 min.)

#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue
 
extern int    BarsBack  = 180;  //how far back to calculate

double u, l, percentage[];

int    limit, i;

int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_%outofBB" + BarsBack + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "percentage");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, percentage);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=Bars-BarsBack; i>=0; i--) {  
      u = iBands(Symbol(), 0, 20, 2, 0, PRICE_MEDIAN, MODE_UPPER, i);
      l = iBands(Symbol(), 0, 20, 2, 0, PRICE_MEDIAN, MODE_LOWER, i);
      //5 cases: bar out of bands on top, on bottom, in bands, or partially bellow or partially above
      if(Low[i]>u) {  //this bar is above bands
         percentage[i] = 100.0;
      }
      
      if(High[i]<l) { //this bar is below bands
         percentage[i] = -100.0;
      }
      
      if(Low[i]>l && High[i]<u) {   //this bar is in bands
         percentage[i] = 0.0;
      }
         
      if(Low[i]<u && High[i]>u) {   //this bar is partially above bands
         percentage[i] = (High[i]-u) / (High[i]-Low[i]) * 100;
      }
      
      if(Low[i]<l && High[i]>l) { //this bar is partially below bands
         percentage[i] = (Low[i]-l) / (High[i]-Low[i]) * 100;
      }
      
   } //close for loop

   return(0);
}

int deinit()  {
   return(0);
}