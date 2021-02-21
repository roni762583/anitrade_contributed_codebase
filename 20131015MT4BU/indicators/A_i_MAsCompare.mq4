// A_i_MAsCompare.mq4
#property copyright "Copyright © 2010, Aharon"

#property indicator_chart_window

#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Blue

#property indicator_color3 Red
#property indicator_color4 Red

#property indicator_color5 Gold
#property indicator_color6 Gold

#property indicator_color7 Green
#property indicator_color8 Green

extern int    Len  = 7;
//extern int    ap_0C_1O_2H_3L_4Med_5Typ_6Wd = 0;
//extern int    ap   = 0;
extern int    Shft = 0;

double smaH[];
double smaL[];

double emaH[];
double emaL[];

double smmaH[];
double smmaL[];

double lwmaH[];
double lwmaL[];

int init()  {
   IndicatorBuffers(8);
   string short_name;
   short_name = "A_i_MAsCompare.mq4(" + Len + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "smaH");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, smaH);
   
   SetIndexLabel(1, "smaL");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, smaL);
   
   SetIndexLabel(2, "emaH");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,emaH);
   
   SetIndexLabel(3, "emaL");
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,emaL);
   
   SetIndexLabel(4, "ssmaH");
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,smmaH);
   
   SetIndexLabel(5, "ssmaL");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,smmaL);
   
   SetIndexLabel(6, "lwmaH");
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,lwmaH);
   
   SetIndexLabel(7, "lwmaL");
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,lwmaL);
   
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
      
      emaH[i] = iMA(NULL, 0, Len, Shft, MODE_EMA, 2, i);
      emaL[i] = iMA(NULL, 0, Len, Shft, MODE_EMA, 3, i);
      
      smmaH[i] = iMA(NULL, 0, Len, Shft, MODE_SMMA, 2, i);
      smmaL[i] = iMA(NULL, 0, Len, Shft, MODE_SMMA, 3, i);
      
      lwmaH[i] = iMA(NULL, 0, Len, Shft, MODE_LWMA, 2, i);
      lwmaL[i] = iMA(NULL, 0, Len, Shft, MODE_LWMA, 3, i);
   }
   /*
   for(i=0; i<limit; i++)  {
      p0 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i);    //avgs represent prices
      p1 =  iCustom(NULL, 0, "Aharon_eFF_C", Period1, Taps1, Window1, 2, i+1);
      p01 = (p0 - p1) * MathPow(10,Digits);
      eFslope_H[i] = p01/t;
   }*/                
   return(0);
}

int deinit()  {
   return(0);
}