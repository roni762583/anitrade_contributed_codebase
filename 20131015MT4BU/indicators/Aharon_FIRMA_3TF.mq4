//+------------------------------------------------------------------+
//|                                           Aharon_FIRMA_3TF.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Purple
//---- external parameters
/*///////////////////              Time Frame Options  /////////////////////////
PERIOD_M1 1 minute. 
PERIOD_M5 5 5 minutes. 
PERIOD_M15 15 15 minutes. 
PERIOD_M30 30 30 minutes. 
PERIOD_H1 60 1 hour. 
PERIOD_H4 240 4 hour. 
PERIOD_D1 1440 Daily. 
PERIOD_W1 10080 Weekly. 
PERIOD_MN1 43200 Monthly. 
0 (zero) 0 Timeframe  
//////////////////////////////////////////////////////////////////////////////*/
extern int    TF1 = 1;
extern int    Period1 = 4;
extern int    Taps1   = 21;  //must be odd number
extern int    Window1   = 4;

extern int    TF2 = 30;
extern int    Period2 = 4;
extern int    Taps2   = 21;  //must be odd number
extern int    Window2   = 4;

extern int    TF3 = 240;
extern int    Period3 = 4;
extern int    Taps3   = 21;  //must be odd number
extern int    Window3   = 4;



//---- buffers
double FIRMA1[];
double FIRMA2[];
double FIRMA3[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(3);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "FMA_3TF(" + TF1 + ", " + TF2 + ", " + TF3 + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"TF1");
   SetIndexLabel(1,"TF2");
   SetIndexLabel(2,"TF3");

                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FIRMA1);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,FIRMA2);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,FIRMA3);

   return(0);
}



//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit()  {

                                //----
   
                                //----
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
   
   

                                                            // Set values
   
   for(i=0; i<limit; i++)  {
   
      FIRMA1[i]= iCustom(NULL, TF1, "Aharon_FIRMA_ARMA", Period1, Taps1, Window1,   0, i);
      
      FIRMA2[i]= iCustom(NULL, TF2, "Aharon_FIRMA_ARMA", Period2, Taps2, Window2,   0, i);
      
      FIRMA3[i]= iCustom(NULL, TF3, "Aharon_FIRMA_ARMA", Period3, Taps3, Window3,   0, i);
     
   }
      
   return(0);

}


