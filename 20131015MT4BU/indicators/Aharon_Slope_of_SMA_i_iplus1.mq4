//+------------------------------------------------------------------+
//|                                 Aharon_Slope_of_SMA_i_iplus1.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

//////////////////////////////////////

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 7
#property  indicator_color1  Silver
#property  indicator_color2  Gold

//---- indicator parameters
extern int MALength =7 ;
//---- indicator buffers
double  Slope[];
double  SlopeMag[];
double AvgSlopeMag[];
double  RTAvg[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
 //  SetIndexDrawBegin(0,(MALength+1));
   //SetIndexDrawBegin(1,(MALength+1));
  
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,Slope);
   SetIndexBuffer(1,RTAvg);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Aharon_Slope_of_SMA("+MALength+")_i_iplus1");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   
  // int period = Period();
   int j;  
   double SP = 0; //s positive, negative
   int C=0; //S= zero counter
   
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//
   
   
   for(int i=Bars; i>0; i--) { 
      Slope[i]=(iMA(NULL,0,MALength,0,MODE_SMA,PRICE_OPEN,i)-iMA(NULL,0,MALength,0,MODE_SMA,PRICE_OPEN,i+1))*MathPow(10,Digits);
   }
   for(i=Bars; i>0; i--) { 
      SlopeMag[i]=MathAbs(Slope[i]);
   }
   for(i=Bars; i>=0; i--) {
         AvgSlopeMag[i]=iMAOnArray(SlopeMag,0,200,0,MODE_SMA,i);
   }  
   
   for(i=Bars; i>=0; i--) {
      if(SlopeMag[i]>AvgSlopeMag[i]) {
         RTAvg[i] = Slope[i];
      }
      else if(MathAbs(Slope[i])<=AvgSlopeMag[i]) {
              RTAvg[i] = 0 //missing ;
           }
   }
   
   //Print("AvgSlopeMag ="+AvgSlopeMag);
   return(0);
  }
//+------------------------------------------------------------------+

