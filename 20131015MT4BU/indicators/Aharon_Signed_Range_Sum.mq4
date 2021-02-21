//+------------------------------------------------------------------+
//|                                      Aharon_Signed_Range_Sum.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Blue
#property indicator_color3 Lime
//---- input parameters
extern int Avg_Len=7;
extern int Avg_Shift=0;
//---- buffers
double Sum[];
double Sum_Avg[];
double OverUnderSum[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

   IndicatorBuffers(3);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
    
   SetIndexBuffer(0,Sum);
   SetIndexBuffer(1,Sum_Avg);
   SetIndexBuffer(2,OverUnderSum);
//---- name for DataWindow and indicator subwindow label
   short_name="A_S_S";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Sum");
   SetIndexLabel(1,"Sum_Avg");
   SetIndexLabel(2,"OverUnder");
//----
   SetIndexDrawBegin(0,Avg_Len);
   SetIndexDrawBegin(1,Avg_Len);
   SetIndexDrawBegin(2,Avg_Len);
//----
   return(0);
  }

int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=Avg_Len) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=Avg_Len;i++) Sum_Avg[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;
   while(i>=0)
     {
     
      Sum[i] = Sum[i+1] + Close[i] - Open[i];
    
      i--;
     }

   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
      Sum_Avg[i]=iMAOnArray(Sum,Bars,Avg_Len,Avg_Shift,MODE_SMA,i);
      
        
        //---
        for(i=1;i<=Avg_Len;i++) Sum_Avg[Bars-i]=0.0;
   i=Bars-counted_bars-1;
   while(i>=0)
     {
     /*
      if(Sum_Avg[i]>Sum[i]) OverUnderSum[i]=OverUnderSum[i+1]-0.0001;
      else
        {
        OverUnderSum[i]=(OverUnderSum[i+1]+0.0001);
        }
    */
       OverUnderSum[i]=OverUnderSum[i+1]+Sum[i]-Sum_Avg[i];
       
      i--;
     }
        //---
   return(0);
  }
//+------------------------------------------------------------------+