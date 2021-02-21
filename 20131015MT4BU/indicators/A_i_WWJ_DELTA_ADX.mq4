//+------------------------------------------------------------------+
//|                                     A_i_WWJ_DELTA_ADX.mq4        |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//trending regime when above ubb (setting), to filter out whipsaw in ma cross type signals
#property copyright "Aharon"
#property link      ""

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
 
extern int    BarsBack       = 500,  //how far back to calculate
              bandsPeriod    = 200, 
              bandsDeviation = 1;
extern double bandsFactor    = 0.60;              

double si[], ubb[], lbb[];

int    limit, i;
double r1, r2, r3, R, K, N;
static int L;

int init()  {
   IndicatorBuffers(3);
   string short_name;
   short_name = "A_i_WWJ_DELTA_ADX(14)";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "DeltaADX");
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
   
  
  
   for(i=Bars-BarsBack; i>=0; i--) { 
      double adx0 = iADX(NULL, 0, 14, 0, 0, i);
      double adx1 = iADX(NULL, 0, 14, 0, 0, i+1);
         si[i] = adx0-adx1; //angle in degrees of delta si / delta time in minutes
      
   }
   
   for(i=BarsBack; i>=0; i--) {
      ubb[i] = iBandsOnArray(si, 0, bandsPeriod, bandsDeviation, 0, MODE_UPPER, i)*bandsFactor;
      //lbb[i] = iBandsOnArray(si, 0, bandsPeriod, bandsDeviation, 0, MODE_LOWER, i)*bandsFactor;
   }

   return(0);
}

int deinit()  {
   return(0);
}