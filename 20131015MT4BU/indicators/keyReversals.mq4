//+------------------------------------------------------------------+
//|                                  maOfMaCrossMa.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White
//#property indicator_color2 Blue
//#property indicator_color3 Red

#property indicator_separate_window

//drawbeggin
//extern int    drawbeggin     = 20;

//parameters for ma on price 
/*
extern int    timeframe1     = 0,//PERIOD_D1, //0 is current chart, otherwise can be passed as parameter from EA for other TF
              period1        = 5, 
              ma_shift1      = 0, 
              ma_method1     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              applied_price1 = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

//parameters for ma on ma
extern int    periodMAonMA   = 5, 
              ma_shift2      = 0, 
              ma_method2     = 0; //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
*/
double l, lm1, lm2, lp1, lp2, h, hm1, hm2, hp1, hp2, sigBuf[];

bool   krh, krl;


int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sigBuf);
   /*
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,maBuf);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,maOnMaBuf);
   
   SetIndexDrawBegin(0,drawbeggin);
   SetIndexDrawBegin(1,drawbeggin);
   SetIndexDrawBegin(2,drawbeggin);
   */
   string s = "keyReversals(-1, 0, 1)";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"sig");
   //SetIndexLabel(1,"ma");
   //SetIndexLabel(2,"maOnMa");
   
   return(0);
}



int start()  {
   int i;
   for(i=2; i<1000; i++)  {
      l = iLow(NULL, 0, i);           //set vars
      lm1 = iLow(NULL, 0, i-1);
      lm2 = iLow(NULL, 0, i-2);
      lp1 = iLow(NULL, 0, i+1);
      lp2 = iLow(NULL, 0, i+2);
      
      h = iHigh(NULL, 0, i);
      hm1 = iHigh(NULL, 0, i-1);
      hm2 = iHigh(NULL, 0, i-2);
      hp1 = iHigh(NULL, 0, i+1);
      hp2 = iHigh(NULL, 0, i+2);
      
      krh = false;                    //reset key reversal flags 
      krl = false;
      
      if(l<lm1 && l<lm2 && l<lp1 && l<lp2)   krl = true; //kr low checked
      
      if(h>hm1 && h>hm2 && h>hp1 && h>hp2)   krh = true; //kr high checked 
      
      if(krl && krh) sigBuf[i] =  -2.0;
      
      if(krl && !krh) sigBuf[i] = -1.0;
      
      if(!krl && krh) sigBuf[i] =  1.0;
      
      if(!krl && !krh) sigBuf[i] = 0.0;
     
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

