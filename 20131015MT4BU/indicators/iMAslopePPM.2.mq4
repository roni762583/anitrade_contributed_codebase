//+------------------------------------------------------------------+
//|                                                iMAslopePPM.2.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//MA slope in pips per minute based on change since 2-bars ago
// .2 version to incorporate s3 per strategy outlined in 1M_strategy.txt 11/01/'12

#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 3
#property indicator_color1 Navy
#property indicator_color2 White
#property indicator_color3 Red

#property indicator_separate_window


//parameters for ma on price 

extern int    period        = 66, 
              shft      = 0, 
              method     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              appldPrc = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

extern bool   testingIndicator = true;
              
extern double stdDevThld = 0.25,
              perCentDropOfsigAsExit = 50.0;

int           bars;
double        sigBuf[], s2[], s3[], ma0, ma1, ma2, ma3, ma4;
static bool   trackExtreme, cockS3;
static double last, slopesSum, slopeAvg, stdDev, devSqSum, extremeValue, sb, lastSB;


int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sigBuf);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,s2);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,s3);
   
   string s = "iMAslopePPM.2("+period+")";
   IndicatorShortName(s);
   IndicatorDigits(Digits);
   SetIndexLabel(0,"sig");
   SetIndexLabel(1,"s2");
   SetIndexLabel(2,"s3");
     
   return(0);
}



int start()  {
   if(testingIndicator)  bars = Bars-period-2;
   else bars = 500;
      
   if(Bars<500) {
      Alert("not enough bars in chart (<500)");
      return(0);
   }
   int i;
   for(i=bars; i>=0; i--)  { 
      ma0=iMA(NULL, 0, period, shft, method, appldPrc, i);
      ma2=iMA(NULL, 0, period, shft, method, appldPrc, i+2);
      
      sigBuf[i] = (ma0-ma2)*MathPow(10,Digits)/(Period()*3);

   }   //close for loop 
   
   slopesSum = 0.0; //zero slopesSum, slopeAvg, devSqSum
   devSqSum  = 0.0;
   slopeAvg  = 0.0;
   stdDev     =0.0;
   for(i=bars; i>=0; i--)  {
      //sum values of slopes
      slopesSum = slopesSum + MathAbs(sigBuf[i]); //treat negative and positive the same
   }
   slopeAvg = slopesSum/bars;  //this will be avg. pos., and its neg. will be avg. neg. slope for simplicity
   
   for(i=bars; i>=0; i--)  {
      //sum deviation squares
      devSqSum = devSqSum + MathPow(MathAbs(sigBuf[i])-slopeAvg, 2);
   }
   
   stdDev = MathSqrt(devSqSum/bars);
   
   double threshold = stdDevThld*stdDev;
   
   for(i=bars; i>=0; i--)  { //builds s2
      s2[i] = 0.0;
      if(sigBuf[i]<0.0 && sigBuf[i]< (-1*slopeAvg-threshold) )   {
         s2[i]=-1.0;
         if(s2[i+1]==0.0)  trackExtreme = true;
      }
      if(sigBuf[i]>0.0 && sigBuf[i]> (slopeAvg+threshold)    )    {
         s2[i]= 1.0;
         if(s2[i+1]==0.0)  trackExtreme = true;
      }
   }
   
   //trackExtreme=false;
   extremeValue=0.0;
   for(i=bars; i>=0; i--)  { //build s3
      s3[i] = 0.0;
      
      sb = sigBuf[i]; //track sigBuf for sign to cock s3
      if((lastSB>0 && sb<0) || (lastSB<0 && sb>0)) { //if sb changed direction
         cockS3=true;                                //turn on flag for s3
      }
      if(lastSB==0.0) {/*special case*/} 
      lastSB = sb; //     
      if( s2[i]== 1 )   {
         //track extreme value
         if( extremeValue<sigBuf[i] ) extremeValue = sigBuf[i]; //update extremeValue
         if( sigBuf[i] <= perCentDropOfsigAsExit*0.01*extremeValue && cockS3)   {
            s3[i] = 1.0;           //exit signal on
            trackExtreme = false;  //turn off tracking of extremum
            cockS3 = false;
         }
      }
      if( s2[i]==-1 )   {
         if( extremeValue>sigBuf[i] ) extremeValue = sigBuf[i]; //update extremeValue
         if( sigBuf[i] >= perCentDropOfsigAsExit*0.01*extremeValue && cockS3)   {
            s3[i] = 1.0;           //exit signal on
            trackExtreme = false;  //turn off tracking of extremum
            cockS3 = false;
         }
      }
      
   }//close for loop for S3
   
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

