//+------------------------------------------------------------------+
//|                                          Aharon_Bands_on_ATR_Mom.mq4 |
//|                      
//|                                    BB(   momentum as change Close[0]-Close[1] over SD  )
//+------------------------------------------------------------------+
#property copyright "Copyright © 20013, Aharon"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 White

extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern int    ATRperiod  =14;


//---- buffers
double D[];
double BBu[];
double Sig[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   IndicatorBuffers(3);

   string short_name;
   short_name="BB_on_ATR_Mom("+ATRperiod+", "+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Momentum(1)/SD");
   SetIndexLabel(1,"Upper");
   SetIndexLabel(3,"Sig");

//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,D);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Sig);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   double sig = 0.0;
   
   for(i=0; i<limit; i++)  {
      D[i]= iATR(Symbol(),0,ATRperiod,i)-iATR(Symbol(),0,ATRperiod,i+1);
   }
   for(i=0; i<limit; i++)  {//Sig is % over UBB, or zero
      sig = iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
      BBu[i]= sig;
      if(D[i]>sig) sig = 100*D[i]/sig;
      else sig = 0.0;
      Sig[i] = sig;
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+