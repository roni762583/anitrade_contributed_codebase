//+------------------------------------------------------------------+
//|                                           A_i_Variance-Ratio.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// Lo and MacKinlay (1988)
//Variance Ratio is HILO(30) range / (ATR(N)*SQRT(N))
//HILO(30) is high-lo range
//VR close to 1 indicates market is in a random walk regime
//VR > 1 indicates market is in a trending regime (with positive autocorrelation of price returns)
//VR < 1 indicates market is in a mean reversion regime (with negative autocorrelation of price returns)

#property copyright "Aharon"
#property link      ""

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 White

 
extern int    N  = 30;  //how far back to calculate

double vr[], inst[];

int    limit, i;
static bool   f = true;

int init()  {
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_i_VR(" + N + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "vr");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, vr);
   
   SetIndexLabel(1, "inst");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, inst);
   
   return(0);
}

int start()  {
   for(i=500; i>=0; i--) {
      double HILO = High[iHighest(NULL, 0, MODE_HIGH, N, i)] - Low[iLowest(NULL, 0, MODE_LOW, N, i)];
      double ATR  = iATR(NULL, 0, N, i);
      Comment(ATR);
      vr[i]= HILO/(ATR*MathSqrt(N));
      inst[i] =(High[i]-Low[i])/(iATR(NULL, 0, N, i)*MathSqrt(N));
   }

   return(0);
}

int deinit()  {
   return(0);
}