//+------------------------------------------------------------------+
//|                                  maOfMaCrossMa.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Blue
#property indicator_color3 Red

#property indicator_separate_window

//drawbeggin
extern int    drawbeggin     = 20;

//parameters for ma on price 
extern int    timeframe1     = 0,//PERIOD_D1, //0 is current chart, otherwise can be passed as parameter from EA for other TF
              period1        = 5, 
              ma_shift1      = 0, 
              ma_method1     = 0, //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 
              applied_price1 = 1; //0=close, 1=open, 2=high, 3=low, 4=median(h+l)/2, 5=typical(h+l+c+)/3 , 6=weighted(H+l+C+c)/4

//parameters for ma on ma
extern int    periodMAonMA   = 5, 
              ma_shift2      = 0, 
              ma_method2     = 0; //0=SMA, 1=EMA, 2=SMMA, 3=LWMA 

double sigBuf[], maBuf[], maOnMaBuf[];
double ma, maOnMa, sig;



int init()  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,sigBuf);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,maBuf);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,maOnMaBuf);
   
   SetIndexDrawBegin(0,drawbeggin);
   SetIndexDrawBegin(1,drawbeggin);
   SetIndexDrawBegin(2,drawbeggin);
   
   string s = "maOfMaCrossMa( period1="+period1+", periodOfMaOnMa= "+periodMAonMA+")";
   IndicatorShortName(s);
   
   SetIndexLabel(0,"sig");
   SetIndexLabel(1,"ma");
   SetIndexLabel(2,"maOnMa");
   
   return(0);
}



int start()  {
   int i;
   for(i=0; i<drawbeggin; i++)  {
      ma = iMA(NULL, timeframe1, period1, ma_shift1, ma_method1, applied_price1, i);
      maBuf[i] = ma;
   }   //close for loop 
   
   
   for(i=0; i<drawbeggin-period1-2; i++)  {
      maOnMa = iMAOnArray(maBuf, 0, periodMAonMA, ma_shift2, ma_method2, i);
      maOnMaBuf[i] = maOnMa;
   }
   
   //draw signal
   //ObjectsDeleteAll(0);
   string n;
   for(i=0; i<drawbeggin; i++)  {
       if(maBuf[i]>maOnMaBuf[i]) {
          sigBuf[i] =  1.0;
        //  n  = "Vline"+i;
        //  ObjectCreate(n, OBJ_VLINE, 0 , Time[i], Close[i]);
        //  ObjectSet(n, OBJPROP_COLOR, Red);
       }
       if(maBuf[i]<maOnMaBuf[i]) {
          sigBuf[i] = -1.0;
        //  n  = "Vline"+i;
        //  ObjectCreate(n, OBJ_VLINE, 0 , Time[i], Close[i]);
        //  ObjectSet(n, OBJPROP_COLOR, Blue);
       }//close if()
   }//close for loop
   
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

