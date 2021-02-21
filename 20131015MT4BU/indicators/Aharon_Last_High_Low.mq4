//+------------------------------------------------------------------+
//|                                         Aharon_Last_High_Low.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 Green
/*/---- input parameters
extern int       SMA5=12;
extern int       SlowEMA=26;
extern int       SignalSMA=9;*/
//---- buffers
double LH=0;        //last high
double LL=0;   //last lo
double LV=0;   //last valley
double LP=0;   //last peak



//---- indicator buffers
double Peaks[];
double Valeys[];
double P[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(5);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Peaks);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,P);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Valleys);
   
   IndicatorDigits(Digits);
//----
//  SetIndexDrawBegin(0,SignalSMA);
   IndicatorDigits(6);
/*/---- indicator buffers mapping
   SetIndexBuffer(0,ExtSilverBuffer);
   SetIndexBuffer(1,ExtMABuffer);
   SetIndexBuffer(2,ExtBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("OsMA("+FastEMA+","+SlowEMA+","+SignalSMA+")");
*///---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i, T;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set SMA array values

  
   // loop over bars in chart left to right
   for(i=0; i<limit; i++)  {
      
      // open price indicator buffer
      P[i] = Open[i];
      
      // if new open is bigger than last high
      if(Open[i] > LH) {
        LH = Open[i];
                
        T = 1;
      } 
      
      // if new open is lower than last lo
      if(Open[i] < LL) {
        LL = Open[i];
        
        T = -1; //toggle
      } 
      
      //if new high is reached, maintain lo,
      if(T==1) {
        Loz[i]=LL;
        LL = LH;
      }
      
      //if new lo is reached, maintain high
      if(T==-1) {
        Hiz[i]=LH;
        LH = LL;
      }
      
      // if no new high or lo reached, maintain both prev. values in buffer
      if(T==0) {
        Hiz[i]=LH;
        Loz[i]=LL;
      }
      
      // reset toggle
      T = 0;
   }
      
   
   
                                                                   
   return(0);
  }