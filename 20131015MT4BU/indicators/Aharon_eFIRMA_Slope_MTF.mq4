//+------------------------------------------------------------------+
//|                                      Aharon_eFIRMA_Slope_MTF.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// 
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Orange
#property indicator_color3 Yellow
#property indicator_color4 Green
#property indicator_color5 Blue
#property indicator_color6 Indigo
#property indicator_color7 Violet

//---- external parameters
extern int Period1 = 20;
extern int Taps1   = 21;
extern int Window1 = 4;

//---- buffers
double M1[];
double M5[];
double M15[];
double M30[];
double M60[];
double M240[];
double M1440[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="Aharon_Slope_MTF";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"M1");
   SetIndexLabel(1,"M5");
   SetIndexLabel(2,"M15");
   SetIndexLabel(3,"M30");
   SetIndexLabel(4,"M60");
   SetIndexLabel(5,"M240");
   SetIndexLabel(6,"M1440");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,M1);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,M5);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,M15);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,M30);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,M60);
   
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,M240);
   
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,M1440);
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
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set values
   for(i=0; i<limit; i++)  {
      M1[i]    = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 1,    Period1, Taps1, Window1);
      M5[i]    = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 5,    Period1, Taps1, Window1);
      M15[i]   = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 15,   Period1, Taps1, Window1);
      M30[i]   = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 30,   Period1, Taps1, Window1);
      M60[i]   = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 60,   Period1, Taps1, Window1);
      M240[i]  = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 240,  Period1, Taps1, Window1);
      M1440[i] = FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 1440, Period1, Taps1, Window1);
   }
   
   /*
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   */
   

//----
   return(0);
  }
//+------------------------------------------------------------------+


////////////////////////////FIRMAslope() defined below ////////////////////////////////////////////////////////////////////////////////////////
double FIRMAslope(double fsa =1.0, double fsb=1.0, double fsc=1.0, int firstbar = 0, int secondbar = 1, int thirdbar = 2, 
                  int TF1 = 0, int Period1 =20, int Taps1=21, int Window1   = 4)  {
double fs = 0.0, d01 = 0.0, d12 = 0.0, d02 = 0.0,
       pi = 3.1415926535897932384626433832795;

   //d01 delta between last two bars (firstbar and secondbar)
   d01 = iCustom(NULL, TF1, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2, firstbar)                       //index; zero is last bar
         -
         iCustom(NULL, TF1, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2,  secondbar);  
         
   //d12 delta between prev.-to-last bar, and two-bars ago (secondbar and thirdbar)
   d12 = iCustom(NULL, TF1, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2,   secondbar)                      //index; zero is last bar
         -
         iCustom(NULL, TF1, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2,  thirdbar);
         
   d02 = d01 + d12;   //delta between last bar, and two-bars-ago (firstbar and thirdbar)
   
   fs = MathArctan(  (  (fsa*d01 + fsb*d12 + fsc*d02)/(fsa + fsb + fsc) * MathPow(10,Digits)   ) / (3*TF1)  )*(180/pi);  //weighed average to quantify slope over last three bars 
   
   return(fs);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////