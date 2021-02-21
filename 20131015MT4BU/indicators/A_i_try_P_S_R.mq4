//+------------------------------------------------------------------+
//|                                                A_i_try_P_S_R.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 Blue

#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red

#property indicator_color5 Green
#property indicator_color6 Green
#property indicator_color7 Green

#property indicator_color8 Yellow 

double  PBuffer[], S1Buffer[], R1Buffer[], S2Buffer[], R2Buffer[], S3Buffer[], R3Buffer[], T[],
        LastHigh, LastLow, P, R1, R2, R3, S1, S2, S3;

int    limit, i;
static int tradedtoday;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   IndicatorBuffers(8);
   string short_name;
   short_name = "A_i_try_P_S_R";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "PBuffer");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, PBuffer);
   
   SetIndexLabel(1, "R1Buffer");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, R1Buffer);
   
   SetIndexLabel(2, "R2Buffer");
   SetIndexStyle(2,  DRAW_LINE);
   SetIndexBuffer(2, R2Buffer);
   
   SetIndexLabel(3, "R3Buffer");
   SetIndexStyle(3,  DRAW_LINE);
   SetIndexBuffer(3, R3Buffer);
   
   SetIndexLabel(4, "S1Buffer");
   SetIndexStyle(4,  DRAW_LINE);
   SetIndexBuffer(4, S1Buffer);
   
   SetIndexLabel(5, "S2Buffer");
   SetIndexStyle(5,  DRAW_LINE);
   SetIndexBuffer(5, S2Buffer);
   
   SetIndexLabel(6, "S3Buffer");
   SetIndexStyle(6,  DRAW_LINE);
   SetIndexBuffer(6, S3Buffer);
   
   SetIndexLabel(7, "T");
   SetIndexStyle(7,  DRAW_LINE);
   SetIndexBuffer(7, T);
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
   int    counted_bars=IndicatorCounted();

   for(i=Bars-2; i>=0; i--)
     {
      if(High[i+1] > LastHigh) LastHigh = High[i+1];
      if(Low[i+1] < LastLow)   LastLow  = Low[i+1];
     
      if(Close[i]>P && Close[i]<R1 && tradedtoday == false)   {
         T[i] =  1.0;
         tradedtoday = true;
      }
      
      if(Close[i]<P && Close[i]>S1 && tradedtoday == false)   {
         T[i] = -1.0;
         tradedtoday = true;
      }
      
      if(TimeDay(Time[i]) != TimeDay(Time[i+1]))
        {
         tradedtoday = false;
         P  = NormalizeDouble( (LastHigh + LastLow + Close[i+1])/3  , Digits);
         R1 = NormalizeDouble(P*2 - LastLow , Digits);
         S1 = NormalizeDouble(P*2 - LastHigh , Digits);
         R2 = NormalizeDouble(P + LastHigh - LastLow , Digits);
         S2 = NormalizeDouble(P - (LastHigh - LastLow) , Digits);
         R3 = NormalizeDouble(P*2 + LastHigh - LastLow*2 , Digits);
         S3 = NormalizeDouble(P*2 - (LastHigh*2 - LastLow) , Digits);
         LastLow  = NormalizeDouble(Open[i] , Digits);
         LastHigh = NormalizeDouble(Open[i] , Digits);
        }
      //----
      PBuffer[i]  = P;
      S1Buffer[i] = S1;
      R1Buffer[i] = R1;
      S2Buffer[i] = S2;
      R2Buffer[i] = R2;
      S3Buffer[i] = S3;
      R3Buffer[i] = R3;
     }
   

   return(0);
}