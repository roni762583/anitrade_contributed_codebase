//+------------------------------------------------------------------+
//|                                             Aharon_Log_Price.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Blue

//input vars
extern int AveragePeriod = 20;                             
extern double Deviations = 2.0;

//---- buffers
double LP[], ALP[], UB[], LB[];                                   // Log(Price)

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(4);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_Log_Price("+AveragePeriod+", "+Deviations+")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Avg. of Log()");
   SetIndexLabel(2,"Upper Band");
   SetIndexLabel(3,"Lower Band");
                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   
   SetIndexBuffer(0,LP);
   SetIndexBuffer(1,ALP);
   SetIndexBuffer(2,UB);
   SetIndexBuffer(3,LB);
   
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

                                                            // Set values   
   for(i=0; i<limit; i++)  {  //Log of Close
      LP[i]= MathLog(Close[i]); 
   }
   
   for(i=0; i<limit; i++)  {  //avg. of lof of price 
      ALP[i]= iMAOnArray(LP, 0, AveragePeriod, 0, 0, i); 
   }
   
   for(i=0; i<limit; i++)  {  //upper band
      UB[i]= ALP[i] + ( Deviations*iStdDevOnArray(LP, 0, AveragePeriod, 0, 0, i) );
   }
   
   for(i=0; i<limit; i++)  {  //lower band
      LB[i]= ALP[i] - ( Deviations*iStdDevOnArray(LP, 0, AveragePeriod, 0, 0, i) ); 
   }

   return(0);
}