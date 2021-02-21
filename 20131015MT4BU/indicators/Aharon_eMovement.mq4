//+------------------------------------------------------------------+
//|                                              Aharon_eMovement.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 White
//#property indicator_color3 Red

extern double Threshold = 12.0;

double mov, ubb, lbb;


//---- buffers
double S[];
double S2[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   //IndicatorBuffers(2);//3);
   IndicatorBuffers(2);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_eMomevent(" + Threshold + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"S");
   SetIndexLabel(1,"S2");
   //SetIndexLabel(2,"Signal3");
                                  //---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
  // SetIndexStyle(2,DRAW_LINE);
   
   SetIndexBuffer(0,S);
   SetIndexBuffer(1,S2);
//   SetIndexBuffer(2,MS);

   return(0);
}



//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}



//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+

int start()   {

   int limit, i;
   int counted_bars=IndicatorCounted();
                                                            //---- check for possible errors
   if(counted_bars<0) return(-1);
                                                            //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)   {
      S[i] = 0.0;
      if(iCustom(NULL, 0, "Aharon_Movement", 1, i) > Threshold) S[i] = 1.0;
   }
   
   for(i=0; i<limit; i++)   {
      S2[i] = iCustom(NULL, 0, "Aharon_Movement", 1, i);
   }
   return(0);
}