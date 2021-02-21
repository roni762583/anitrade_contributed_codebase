//+------------------------------------------------------------------+
//|                                A_Slope_Overshoot_To_BW_Ratio.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                            Aharon_FMSlopeWBBpercentOvershoot.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                     Aharon_FMSlopeWBBOrdered.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// single indicator based on slope est. with bolinger bands indicator:
// if slope outside BB: +1 is BUY if Flat, -1 is SELL if flat
// if slope inside BB: 0 Flatten all positions


#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
//extern int    SigPeriod = 5;
extern double ThldDecimal = 1.0;                           //Threshold multiple above/below bands

//---- buffers
double S[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_Slope_Overshoot_To_BW_Ratio("+BandsDeviations+", "+BandsPeriod+", Thld:"+ThldDecimal+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Signal");
   

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,S);
//----
   return(0);
  }


int start()   {
   int limit, i;
   int counted_bars=IndicatorCounted();
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   // Set values of signal array 
   for(i=0; i<limit; i++)  {  //from last going back
   
      //check if slope signal is above Upper band by threshold decimal
      if(iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i)  >= 
         iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 1, i) * ThldDecimal)   {//0 is signal, 1 is ubb, 2 is lbb
         
         S[i]= ( iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i) -   //signal - ubb
                  iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 1, i) ) / //divided
               ( iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 1, i) -   //ubb - lbb
                  iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 2, i) );  
      }
      
      //check if slope signal is below Lower band by threshold decimal
      if(iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i)  <=
         iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 2, i) * ThldDecimal)   {
         
         S[i]= ( iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i) -
                  iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 2, i) ) /
               ( iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 1, i) -
                  iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 2, i) );   //down signal
      }
      //the equal sign above can create a situation where the output signal is NULL !
      
      //check if slope signal is between bands
      if(iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i)  <
         iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 1, i) &&   //strictly below Upper band
         
         iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 0, i)  >   //AND, strictly above Lower band => FLATTEN POS.
         iCustom(NULL, 0, "Aharon_FIRMA_Slope_w_BB", BandsDeviations, BandsPeriod, 2, i) )   {
      S[i]= 0;   // signal FLATTEN OPEN POSITION/S
      }
   
   }  //closes the for loop
   
   return(0);
}    //closes start function


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
//----
   
//----
   return(0);
}

/*
//+------------------------------------------------------------------+
//|                                      Aharon_FIRMA_Slope_w_BB.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// THIS ESTIMATES THE SLOPE OVER THE LAST THREE BARS BY WEIGHT AVERAGE OF THE DIFFERENCES BETWN. THE THREE
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
//extern int    SigPeriod = 5;

//---- buffers
double D[];
double BBu[];
double BBl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="Aharon_FIRMA_Slope_Est_BB("+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Slope");
   SetIndexLabel(1,"Upper");
   SetIndexLabel(2,"Lower");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl);
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
           
      D[i]= FIRMAslope(1.0, 1.0, 1.0, i, (i+1), (i+2), 0, 4, 21, 4, 3, 0, 2, 3, 0, 2, 1, 14, 2, 0);
   }
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+


////////////////////////////FIRMAslope() defined below ////////////////////////////////////////////////////////////////////////////////////////
double FIRMAslope(double fsa =1.0, double fsb=1.0, double fsc=1.0, int firstbar = 0, int secondbar = 1, int thirdbar = 2, int TF1 =0, 
                  int Period1 =4, int Taps1=21, int Window1   = 4, int    MA1Period = 3, int    MA1shift = 0, int    MA1method   = 2,
                  int MA2Period = 3, int MA2shift = 0, int MA2method = 2,
                  int MomLength = 1, int BBPeriod = 14, int BBDeviations = 2, int BBShift = 0)  {
double fs = 0.0, d01 = 0.0, d12 = 0.0, d02 = 0.0;

   //d01 delta betweeen last two bars (firstbar and secondbar)
   d01 = iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     firstbar)                       //index; zero is last bar
        -
         iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     secondbar);  
   //d12 delta between prev.-to-last bar, and two-bars ago (secondbar and thirdbar)
   d12 = iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     secondbar)                      //index; zero is last bar
        -
         iCustom(NULL, TF1, "Aharon_FIRMA_MA_MA_Full_Momentum_W_BB", TF1, Period1, Taps1, Window1,      
                                                                     MA1Period, MA1shift, MA1method, //MA Method: 0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                                     MA2Period, MA2shift, MA2method,
                                                                     MomLength,                      //length for momentum
                                                                     BBPeriod, BBDeviations, BBShift,
                                                                     0,                              //0 is FIRMA_Full
                                                                                                     //1 is MA1
                                                                                                     //2 is MA2
                                                                                                     //3 is Momentum line buffer index
                                                                                                     //4 is UBB
                                                                                                     //5 is LBB
                                                                     thirdbar);
   d02 = d01 + d12;   //delta between last bar, and two-bars-ago (firstbar and thirdbar)
   
   fs = ((fsa*d01 + fsb*d12 + fsc*d02)/(fsa + fsb + fsc)) * MathPow(10,Digits);  //weighed average to quantify slope over last three bars 
   
      return(fs);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

*/


