//+------------------------------------------------------------------+
//|                                             FIRMA_MA_MA_Full.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           Aharon_FIRMA_MA_MA.mq4 |
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
//#property indicator_color4 Red

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
//default values correspond to tested values
extern int    TF1 = 0;       
extern int    Period1 = 20;
extern int    Taps1   = 21;     //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 15;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 20;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA


//---- buffers
double FIRMA[];
double MA1[];
double MA2[];
//double Ordered[];

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(3);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "FIRMA_MA_MA_Full(" + Period1 + ", " + MA1Period + ", " + MA2Period + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"FIRMA");
   SetIndexLabel(1,"MA1");
   SetIndexLabel(2,"MA2");
   //SetIndexLabel(3,"Ordered");

                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FIRMA);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA1);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MA2);
   
   //SetIndexStyle(3,DRAW_LINE);
   //SetIndexBuffer(3,Ordered);

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
   
      FIRMA[i]= iCustom(NULL, TF1, "Aharon_FIRMA_Full", Period1, Taps1, Window1,   2, i);
     
   }
    
   for(i=0; i<limit; i++)  {
   
      MA1[i]= iMAOnArray(FIRMA, 0, MA1Period, MA1shift, MA1method , i);
     
   } 
         
   for(i=0; i<limit; i++)  {
   
      MA2[i]= iMAOnArray(MA1, 0, MA2Period, MA2shift, MA2method , i);
     
   } 
         
   return(0);

}


