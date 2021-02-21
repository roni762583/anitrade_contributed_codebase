//+------------------------------------------------------------------+
//|                                  kalman crossing open median.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White

#property indicator_separate_window

extern int    modeA      = 1;             
extern double kA         = 1.0, 
              sharpnessA = 1.0;
extern int    modeB      = 1;
extern double kB         = 5.0, 
              sharpnessB = 5.0;
              


double Buffer[];
double ko, km, k00, k01, k10, k11, dir = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   //SetIndexStyle(1,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   //SetIndexDrawBegin(0,draw_begin);
   //SetIndexDrawBegin(1,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,Buffer);
   string s = "kalmanCross("+modeA+","+kA+","+sharpnessA+","+modeB+","+kB+","+sharpnessB+")";
   IndicatorShortName(s);
   SetIndexLabel(0,"ind");
   //SetIndexBuffer(1,ExtMapBufferDown);
//---- initialization done
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
      k10 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 0, i); //kalman median price 
      k11 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 1, i); //kalman median price 
      if(k00>9999) ko = k01;
      if(k01>9999) ko = k00;
      if(k10>9999) km = k11;
      if(k11>9999) km = k10;
      dir = 0.0;
      if(km>ko) dir = 1.0;  //up
      if(km<ko) dir = -1.0; //down
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

