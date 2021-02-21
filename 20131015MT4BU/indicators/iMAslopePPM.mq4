//+------------------------------------------------------------------+
//|                                                 iMAslopePPM.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//MA slope in pips per minute based on change since 2-bars ago

#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
//#property indicator_color3 Red

#property indicator_separate_window

//drawbeggin
//extern int    drawbeggin     = 20;

//parameters for ma on price 

extern int    period        = 21, 
              shft      = 0, 
              method     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              appldPrc = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4
              
extern double stdDevThld = 1.2;
/**/
//parameters for ma on ma
//extern int    atrPeriod   = 14; 
          //    ma_shift2      = 0, 
          //    ma_method2     = 0; //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 

double sigBuf[], s2[], ma0, ma1, ma2, ma3, ma4;
static double last, slopesSum, slopeAvg, stdDev, devSqSum;
//bool   krh, krl;


int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sigBuf);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,s2);
   
   string s = "iMAslopePPM("+period+")";
   IndicatorShortName(s);
   IndicatorDigits(Digits);
   SetIndexLabel(0,"sig");
   SetIndexLabel(1,"s2");
   //SetIndexLabel(2,"maOnMa");
     
   return(0);
}



int start()  {
   if(Bars<500) {
      Alert("not enough bars in chart (<500)");
      return(0);
   }
   int i;
   for(i=500; i>=0; i--)  {
      ma0=iMA(NULL, 0, period, shft, method, appldPrc, i);
     // ma1=iMA(NULL, 0, period, shft, method, appldPrc, i+1);
      ma2=iMA(NULL, 0, period, shft, method, appldPrc, i+2);
     // ma3=iMA(NULL, 0, period, shft, method, appldPrc, i+3);
     // ma4=iMA(NULL, 0, period, shft, method, appldPrc, i+4);
      
      
      sigBuf[i] = (ma0-ma2)*MathPow(10,Digits)/(Period()*3);

   }   //close for loop 
   
   slopesSum = 0.0; //zero slopesSum, slopeAvg, devSqSum
   devSqSum  = 0.0;
   slopeAvg  = 0.0;
   stdDev     =0.0;
   for(i=500; i>=0; i--)  {
      //sum values of slopes
      slopesSum = slopesSum + MathAbs(sigBuf[i]); //treat negative and positive the same
   }
   slopeAvg = slopesSum/500;  //this will be avg. pos., and its neg. will be avg. neg. slope for simplicity
   
   for(i=500; i>=0; i--)  {
      //sum deviation squares
      devSqSum = devSqSum + MathPow(MathAbs(sigBuf[i])-slopeAvg, 2);
   }
   
   stdDev = MathSqrt(devSqSum/500);
   
   double threshold = stdDevThld*stdDev;
   
   for(i=500; i>=0; i--)  {
      s2[i] = 0.0;
      if(sigBuf[i]<0.0 && sigBuf[i]< (-1*slopeAvg-threshold) ) s2[i]=-1.0;
      if(sigBuf[i]>0.0 && sigBuf[i]> (slopeAvg+threshold) )    s2[i]= 1.0;
   }
   
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

