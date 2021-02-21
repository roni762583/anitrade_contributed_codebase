//+------------------------------------------------------------------+
//|                                             Aharon_ATR_Cross.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Blue
//---- input parameters
extern int AtrPeriod=14;
extern int AtrPeriod2=14;
//---- buffers
double AtrBuffer[];
double TempBuffer[];

double AtrBuffer2[];
double TempBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(4);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AtrBuffer);
   SetIndexBuffer(1,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="ATR("+AtrPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,AtrPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AtrPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=AtrPeriod;i++) AtrBuffer[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;
   while(i>=0)
     {
      double high=High[i];
      double low =Low[i];
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
        {
         double prevclose=Close[i+1];
         TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
        }
      i--;
     }
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
      AtrBuffer[i]=iMAOnArray(TempBuffer,Bars,AtrPeriod,0,MODE_SMA,i);
//----
///////////////////////////////////////////////////////////////////////////////////////////////////////////
 int i2,counted_bars2=IndicatorCounted();
//----
   if(Bars<=AtrPeriod2) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i2=1;i2<=AtrPeriod2;i2++) AtrBuffer2[Bars-i2]=0.0;
//----
   i2=Bars-counted_bars2-1;
   while(i>=0)
     {
      double high2=High[i2];
      double low2 =Low[i2];
      if(i2==Bars-1) TempBuffer2[i]=high2-low2;
      else
        {
         double prevclose2=Close[i2+1];
         TempBuffer2[i]=MathMax(high2,prevclose2)-MathMin(low2,prevclose2);
        }
      i2--;
     }
//----
   if(counted_bars2>0) counted_bars2--;
   int limit2=Bars-counted_bars2;
   for(i2=0; i2<limit2; i2++)
      AtrBuffer2[i2]=iMAOnArray(TempBuffer2,Bars,AtrPeriod2,0,MODE_SMA,i2);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   return(0);
  }
//+------------------------------------------------------------------+-----------+