//+------------------------------------------------------------------+
//|                                             Aharon_eFIRMXMMF.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//this is to reduce Aharon_FIRMXMMF.mq4 to single buffer for ease in viewing


#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue


extern int    TF1 = 0;       
extern int    Period1 = 20;
extern int    Taps1   = 21;     //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 2;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 2;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA


//---- buffers
double S[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   //IndicatorBuffers(2);//3);
   IndicatorBuffers(1);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_eFIRMXMMF(" + TF1 + ", " + Period1 + ", " + Taps1 + ", " + Window1 + ", " + MA1Period + ", " + 
                                  MA1shift + ", " + MA1method + ", " + MA2Period + ", " + MA2shift + ", " + MA2method + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Signal");
                                  //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   
   SetIndexBuffer(0,S);

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
      S[i] = iCustom(NULL, 0, "Aharon_FIRMXMMF", 
                     TF1, Period1, Taps1, Window1, MA1Period, MA1shift, MA1method, MA2Period, MA2shift, MA2method,
                     3, i);
   }
   
}