//+------------------------------------------------------------------+
//|                                  kalmanCrossSMA.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White

#property indicator_separate_window

extern int    modeA         = 1;             
extern double kA            = 5.0, 
              sharpnessA    = 5.0;

extern int    period        = 5, 
              ma_shift      = 0, 
              ma_method     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              applied_price = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4



double Buffer[];
double ko, km, k00, k01, ma, dir = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer);
   
   string s = "kalmanCrossSMA("+modeA+","+kA+","+sharpnessA+",  2nd("+period+")";
   IndicatorShortName(s);
   SetIndexLabel(0,"ind");
  
   return(0);
  }



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
  // int    counted_bars=IndicatorCounted();

   for(int i=0; i<500; i++)  {
      k00 = iCustom(NULL, 0, "kalman filter", modeA, kA, sharpnessA, 500, 0, i); //kalman open price
      k01 = iCustom(NULL, 0, "kalman filter", modeA, kA, sharpnessA, 500, 1, i); //kalman open price
      //k10 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 0, i); //kalman median price 
      //k11 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 1, i); //kalman median price 
      ma = iMA(NULL, 0, period, ma_shift, ma_method, applied_price, i);
      if(k00>9999) ko = k01;
      if(k01>9999) ko = k00;
     // if(k10>9999) km = k11;
     // if(k11>9999) km = k10;
      dir = 0.0;
      if(ma>ko) dir = -1.0;  //up
      if(ma<ko) dir = 1.0; //down
      Buffer[i] = dir;  //neither */
   }   //close for loop 
   
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

