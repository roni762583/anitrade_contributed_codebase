//+------------------------------------------------------------------+
//|                                                 iMAchangeDir.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//indicator will show when MA of last two bars is lower than peak (defined as highest middle among five bars), and vice versa for opposite direction

#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 Yellow


#property indicator_separate_window


extern int    period   = 21, 
              shft     = 0, 
              method   = 0,   //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              appldPrc = 1;   //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

double        sigBuf[], ma0, ma1, ma2, ma3, ma4;
static double last;



int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sigBuf);

   string s = "iMAchangeDir("+period+")";

   IndicatorShortName(s);
   IndicatorDigits(Digits);
   SetIndexLabel(0,"sig");
     
   return(0);
}



int start()  {
   
   int i;
   for(i=500; i>=0; i--)  {
      ma0=iMA(NULL, 0, period, shft, method, appldPrc, i);
      ma1=iMA(NULL, 0, period, shft, method, appldPrc, i+1);
      ma2=iMA(NULL, 0, period, shft, method, appldPrc, i+2);
   // ma3=iMA(NULL, 0, period, shft, method, appldPrc, i+3);
   // ma4=iMA(NULL, 0, period, shft, method, appldPrc, i+4);
      
      if(  ma0>ma1 && ma1<ma2 ) last =  1.0;
         
      if(  ma0<ma1 && ma1>ma2 ) last = -1.0;
        
      sigBuf[i] = last; 
      
      //if(i==0) sigBuf[0] = last; 
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

