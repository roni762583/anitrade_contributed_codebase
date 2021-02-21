//+------------------------------------------------------------------+
//|                                  2MAsOnChart.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Blue
#property indicator_chart_window

extern int    timeframe1     = 60,
              period1        = 5, 
              ma_shift1      = 0, 
              ma_method1     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              applied_price1 = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

extern int    timeframe2     = 240,
              period2        = 5, 
              ma_shift2      = 0, 
              ma_method2     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              applied_price2 = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

double ma1Buf[], ma2Buf[];
double ma1, ma2;



int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ma1Buf);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ma2Buf);
   
   string s = "2MAs("+timeframe1+","+period1+","+ma_shift1+","+ma_method1+","+applied_price1+
              ",  2nd MA "+timeframe2+","+period2+","+ma_shift2+","+ma_method2+","+applied_price2+")";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"ma1");
   SetIndexLabel(1,"ma2");
  
   return(0);
  }



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
  // int    counted_bars=IndicatorCounted();

   for(int i=0; i<500; i++)  {
      //k00 = iCustom(NULL, 0, "kalman filter", modeA, kA, sharpnessA, 500, 0, i); //kalman open price
      //k01 = iCustom(NULL, 0, "kalman filter", modeA, kA, sharpnessA, 500, 1, i); //kalman open price
      //k10 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 0, i); //kalman median price 
      //k11 = iCustom(NULL, 0, "kalman filter", modeB, kB, sharpnessB, 500, 1, i); //kalman median price 
      ma1 = iMA(NULL, timeframe1, period1, ma_shift1, ma_method1, applied_price1, i);
      ma2 = iMA(NULL, timeframe2, period2, ma_shift2, ma_method2, applied_price2, i);
      //if(k00>9999) ko = k01;
      //if(k01>9999) ko = k00;
     // if(k10>9999) km = k11;
     // if(k11>9999) km = k10;
      //dir = 0.0;
      //if(ma>ko) dir = -1.0;  //up
      //if(ma<ko) dir = 1.0; //down
      ma1Buf[i] = ma1;  //
      ma2Buf[i] = ma2;  //
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

