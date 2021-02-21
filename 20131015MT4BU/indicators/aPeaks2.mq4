//+------------------------------------------------------------------+
//|                                                  aPeaks2.mq4 |
//note: uses aPeaks.mq4 ind. to identify last two extremums, then print a slope of the trend: ERROR DIVIDE BY ZERO!



#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 1
#property  indicator_color1  White

double     SignalBuffer[];

double     low1  = 0.0, low2  = 0.0, hi1 = 0.0, hi2 = 0.0;

datetime   lotm1, lotm2, hitm1, hitm2;

extern int len = 5; //length of ma

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   
   
   IndicatorDigits(6);
//---- indicator buffers mapping
   
   SetIndexBuffer(0,SignalBuffer);  //SignalBuffer
  
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Peaks2");
   SetIndexLabel(0,"SignalBuff.");
   
   return(0);
  }
  

int start()   {
   
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;


   lotm1 = 0.0;
   lotm2 = 0.0;
   low1  = 0.0;
   low2  = 0.0;
   
   hitm1 = 0.0;
   hitm2 = 0.0;
   hi1  = 0.0;
   hi2  = 0.0;

   for(int i=0; i<limit; i++)   {
      
      double a = iCustom(NULL, 0, "aPeaks", len, 1, i);
      /////////////////////////////////////////////////////////////
      if(low2!=0.0 && low1!=0.0) break; //if both found, break
      if(low2==0.0 && low1==0.0 && a>0.0)   {  //if none found...
         lotm2 = Time[i];
         low2  = Low[i];
         int iteration = i;
      }
      if(low2!=0.0 && low1==0.0 && a>0.0 && i>iteration)   {  //if one found...
         lotm1 = Time[i];
         low1  = Low[i];
      }
      /////////////////////////////////////////////////////////////
      if(hi2!=0.0 && hi1!=0.0) break; //if both found, break
      if(hi2==0.0 && hi1==0.0 && a<0.0)   {  //if none found...
         hitm2 = Time[i];
         hi2  = High[i];
         int iteration2 = i;
      }
      if(hi2!=0.0 && hi1==0.0 && a<0.0 && i>iteration2)   {  //if one found...
         hitm1 = Time[i];
         hi1  = High[i];
      }
      /////////////////////////////////////////////////////////////      
   }   
   
   Print("slp1=", ((low2-low1)/Point)/(lotm2-lotm1), "    slp2=", ((hi2-hi1)/Point)/(hitm2-hitm1) );

   return(0); 
}
  

