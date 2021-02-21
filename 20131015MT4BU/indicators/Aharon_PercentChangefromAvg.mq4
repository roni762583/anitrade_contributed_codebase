//+------------------------------------------------------------------+
//|                                  Aharon_PercentChangefromAvg.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                         Aharon_PercentChange.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow

//input vars
extern int    AveragePeriod = 20;
extern double Deviations = 2.0;

//---- buffers
double PCFA[], ub[], LB[];

//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(3);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Pct Chng From Avg("+AveragePeriod+", "+Deviations+")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Pct Chng From Avg");
   SetIndexLabel(1,"ub");
   SetIndexLabel(2,"lb");
                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
 
   SetIndexBuffer(0,PCFA);
   SetIndexBuffer(1,ub);   
   SetIndexBuffer(2,LB);
   
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
   for(i=0; i<limit; i++)  {  //percent change from average
      PCFA[i]= (Close[i]-iMA(NULL, 0, AveragePeriod, 0, 0, PRICE_CLOSE, i+1))*100/iMA(NULL, 0, AveragePeriod, 0, 0, PRICE_CLOSE, i+1);
   }
   for(i=0; i<limit; i++)  {  //ubb
      ub[i]= 1.0;                            //////debug here
   }
   
   
   return(0);
}