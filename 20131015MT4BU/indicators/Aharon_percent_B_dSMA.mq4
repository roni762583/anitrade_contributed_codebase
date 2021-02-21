//+------------------------------------------------------------------+
//|                                        Aharon_percent_B_dSMA.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
//#property indicator_color2 Blue
/*#property indicator_color3 Blue
#property indicator_color4 Gold
#property indicator_color5 Violet*/

//---- buffers
double D[];
//double BBu[];
//double BBl[];
double PerB[];
//double BW[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,PerB);
   SetIndexBuffer(1,D);
   /*SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl); 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,PerB);*/
//   SetIndexStyle(4,DRAW_LINE);
  // SetIndexBuffer(4,BW);
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
   int limit, i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set values
   for(i=0; i<limit; i++)  {
      D[i]=(iMA(NULL, 0, 5, 0, 0, PRICE_OPEN, i)-iMA(NULL, 0, 10, 0, 0, PRICE_OPEN, i));
   }
   for(i=0; i<limit; i++)  {
     //BBu[i]=iBandsOnArray(D, 0, 20, 2, 0, 1,i);
     //BBl[i]=iBandsOnArray(D, 0, 20, 2, 0, 2,i);
     PerB[i] = (D[i] - (iBandsOnArray(D, 0, 20, 2, 0, 2,i))) / ((iBandsOnArray(D, 0, 20, 2, 0, 1,i))-(iBandsOnArray(D, 0, 20, 2, 0, 2,i))) * 100; //this works, but in bigger scale
   }
   //                                                  PerB = (last - lower band) / (upper -lower)
   //                BW = (upper -lower) / middle
   for(i=0; i<limit; i++)    
   {
      
     
     // BW[i] = ((BBu[i] - BBl[i]) );               // (iMAOnArray(D, 0, 20, 0, MODE_SMA, i) );
      
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+