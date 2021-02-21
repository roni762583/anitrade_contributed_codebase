//+------------------------------------------------------------------+
//|                                     A_i_WWJ_ASI-messWithL-BB.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
 
extern int    BarsBack       = 500,  //how far back to calculate
              bandsDeviation = 1,
              bandsPeriod    = 20;

extern double bandsFactor    = 1.0;

double si[], ubb[], lbb[];

int    limit, i;
double r1, r2, r3, R, K, N;
static int L;

int init()  {
   IndicatorBuffers(3);
   string short_name;
   short_name = "A_i_WWJ_SI-BB(" + BarsBack + ", " + bandsDeviation + ", " + bandsPeriod + ", " + bandsFactor + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "si");
   SetIndexStyle(0,  DRAW_HISTOGRAM);
   SetIndexBuffer(0, si);
   
   SetIndexLabel(1, "ubb");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, ubb);
   
   
   SetIndexLabel(2, "lbb");
   SetIndexStyle(2,  DRAW_LINE);
   SetIndexBuffer(2, lbb);
   
   
   for(int i=0; i<Bars; i++)   {
      L = MathMax((High[i]-Low[i])/Point, L); //
   }
   //if(L<1) L = 1;
   L=L/10;
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
  
   if(L<1) L = 1;
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
         si[i] = MathRound((50*( N / R ) * (K/L))/Point);
      }   
         else si[i] = si[i+1];
   }
   
   for(i=BarsBack; i>=0; i--) {
      ubb[i] = iBandsOnArray(si, 0, bandsPeriod, bandsDeviation, 0, MODE_UPPER, i)*bandsFactor;
      lbb[i] = iBandsOnArray(si, 0, bandsPeriod, bandsDeviation, 0, MODE_LOWER, i)*bandsFactor;
   }

   return(0);
}

int deinit()  {
   return(0);
}