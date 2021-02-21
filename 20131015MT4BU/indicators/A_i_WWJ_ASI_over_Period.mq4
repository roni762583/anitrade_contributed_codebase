//+------------------------------------------------------------------+
//|                                      A_i_WWJ_ASI_over_Period.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
 
extern int    BarsBack  = 180;  //how far back to calculate

double siop[], asi[];

int    limit, i, L;
double r1, r2, r3, R, K, N;


int init()  {
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_i_WWJ_ASI_over_Period(" + BarsBack + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "siop");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, siop);
   
   SetIndexLabel(1, "asi");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, asi);
   
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=Bars-BarsBack; i>=0; i--) {  //This replaces the Limit Move in the Wilder calculation, however, it will prevent 100 poind days!
      L = MathMax((High[i]-Low[i])/Point, L); //check if works
   }
   
  //Add start date for for loop
   for(i=Bars-BarsBack; i>=0; i--) { 
      r1 = MathAbs(High[i] - Close[i+1]);
      r2 = MathAbs(Low[i]  - Close[i+1]);
      r3 = MathAbs(High[i]  - Low[i]);
      
      if(r1 == MathMax(r1, MathMax(r2, r3)))   R = r1 - 0.5*r2 + 0.25*MathAbs(Close[i+1]-Open[i+1]);
      if(r2 == MathMax(r1, MathMax(r2, r3)))   R = r2 - 0.5*r1 + 0.25*MathAbs(Close[i+1]-Open[i+1]);
      if(r3 == MathMax(r1, MathMax(r2, r3)))   R = r3 + 0.25*MathAbs(Close[i+1]-Open[i+1]);
      
      K = MathMax(r1, r2);
      
      N = (Close[i]-Close[i+1]) + 0.5*(Close[i]-Open[i]) + 0.25*(Close[i+1]-Open[i+1]);
      
      if(R != 0)   {
         siop[i] = MathRound((50*( N / R ) * (K/L))/Point) / Period();
      }   
         else siop[i] = siop[i+1];
   }
   
   for(i=BarsBack; i>=0; i--) {
      asi[BarsBack + 1] = 0;
      asi[i] = asi[i+1] + siop[i];
   }

   return(0);
}

int deinit()  {
   return(0);
}