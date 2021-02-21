// A_i_SMA_HL.mq4
#property copyright "Copyright © 2010, Aharon"

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Blue

#property indicator_color3 Red
#property indicator_color4 Red

#property indicator_color5 Yellow
/*
#property indicator_color5 Gold
#property indicator_color6 Gold

#property indicator_color7 Green
#property indicator_color8 Green
*/
extern int    Len  = 7;
extern int    MaMaLen = 7;
extern int    Shft = 0;

double smaH[];
double smaL[];
double smamaH[];
double smamaL[];
double div[];

int init()  {
   IndicatorBuffers(5);
   string short_name;
   short_name = "A_i_SMA_HL(" + Len + "," + MaMaLen + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "smaH");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, smaH);

   SetIndexLabel(1, "smaL");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, smaL);
  
   SetIndexLabel(2, "smamaH");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,smamaH);

   SetIndexLabel(3, "smamaL");
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,smamaL);

   SetIndexLabel(4, "div");
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,div);
/*             
   SetIndexLabel(5, "ssmaL");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,smmaL);
   
   SetIndexLabel(6, "lwmaH");
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,lwmaH);
   
   SetIndexLabel(7, "lwmaL");
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,lwmaL);
*/   
   return(0);
}

int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      smaH[i] = iMA(NULL, 0, Len, Shft, MODE_SMA, 2, i);
      smaL[i] = iMA(NULL, 0, Len, Shft, MODE_SMA, 3, i);
  
    /*  
      emaH[i] = iMA(NULL, 0, Len, Shft, MODE_EMA, 2, i);
      emaL[i] = iMA(NULL, 0, Len, Shft, MODE_EMA, 3, i);
      
      smmaH[i] = iMA(NULL, 0, Len, Shft, MODE_SMMA, 2, i);
      smmaL[i] = iMA(NULL, 0, Len, Shft, MODE_SMMA, 3, i);
      
      lwmaH[i] = iMA(NULL, 0, Len, Shft, MODE_LWMA, 2, i);
      lwmaL[i] = iMA(NULL, 0, Len, Shft, MODE_LWMA, 3, i);  */
   }
   /*
   for(i=0; i<limit; i++)  {
      p0 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i);    //avgs represent prices
      p1 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i+1);
      p01 = (p0 - p1) * MathPow(10,Digits);
      eFslope_H[i] = p01/t;
   }*/                
   for(i=0; i<limit; i++)  {
      smamaH[i] = iMAOnArray(smaH, 0, MaMaLen, 0, MODE_SMA, i);
      smamaL[i] = iMAOnArray(smaL, 0, MaMaLen, 0, MODE_SMA, i);
   }
   
   for(i=0; i<limit; i++)  {
      if(   (smaH[i]>smamaH[i] && smaL[i]<smamaL[i])  ||
            (smaH[i]<smamaH[i] && smaL[i]>smamaL[i])
         )  div[i] = Low[i] -5*Point;
   }

   return(0);
}

int deinit()  {
   return(0);
}