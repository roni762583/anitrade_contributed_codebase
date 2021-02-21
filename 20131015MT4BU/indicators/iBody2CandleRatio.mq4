//+------------------------------------------------------------------+
//|                                  iBody2CandleRatio.mq4                  |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//take ration of candle body to total range (close-open)/(high-low)
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
extern int    period        = 5, 
              shft      = 0, 
              method     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              appldPrc = 0; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

//parameters for ma on ma
extern int    periodMAonMA   = 5, 
              ma_shift2      = 0, 
              ma_method2     = 0; //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
*/
double sigBuf[];

//bool   krh, krl;


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
   string s = "iBody2CandleRatio()";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"sig");
   //SetIndexLabel(1,"ma");
   //SetIndexLabel(2,"maOnMa");
   
   return(0);
}



int start()  {
   int i;
   for(i=0; i<Bars-1; i++)  {
      sigBuf[i] = (Close[i]-Open[i])/(High[i]-Low[i]);
     
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

