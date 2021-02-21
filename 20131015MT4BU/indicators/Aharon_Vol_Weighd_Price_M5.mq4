//+------------------------------------------------------------------+
//|                                   Aharon_Vol_Weighd_Price_M5.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 DodgerBlue

//---- buffers
double Vol_W_Prc[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string short_name;
   IndicatorBuffers(1);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Vol_W_Prc);

//---- name for DataWindow and indicator subwindow label
   short_name="Aharon_Vol_Weighd_Price";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,0);
//----
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
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i, counted_bars=IndicatorCounted();
//----
   for(i=Bars - 6; i>0; i--)
     {
       Vol_W_Prc[i]= iVolume(NULL, 0, i);/*
     ( (((High[i]+Low[i])/2)*iVolume(NULL, 1, i))+
       (((High[i+1]+Low[i+1])/2)*iVolume(NULL, 1, i+1))+
       (((High[i+2]+Low[i+2])/2)*iVolume(NULL, 1, i+2))+
       (((High[i+3]+Low[i+3])/2)*iVolume(NULL, 1, i+3))+
       (((High[i+4]+Low[i+4])/2)*iVolume(NULL, 1, i+4)) )/
       (  iVolume(NULL, 1, i)+
          iVolume(NULL, 1, i+1)+
          iVolume(NULL, 1, i+2)+
          iVolume(NULL, 1, i+3)+
          iVolume(NULL, 1, i+4) ) ; */
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+