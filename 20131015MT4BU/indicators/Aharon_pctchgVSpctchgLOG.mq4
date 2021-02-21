//+------------------------------------------------------------------+
//|                                     Aharon_pctchgVSpctchgLOG.mq4 |
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
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Pink
#property indicator_color5 Pink

//input vars
extern int    AvgPriod = 20;
extern double Deviations = 2.0;

//---- buffers
double P[];                                   // percent change
double LP[], diff[], UB[], LB[];
//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(5);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_pctchgVSpctchgLOG("+AvgPriod+", "+Deviations+")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Avg");
   SetIndexLabel(2,"diff");
   SetIndexLabel(3,"UB");
   SetIndexLabel(4,"LB");
                               //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);

   SetIndexBuffer(0,P);
   SetIndexBuffer(1,LP);
   SetIndexBuffer(2,diff);
   SetIndexBuffer(3,UB);   
   SetIndexBuffer(4,LB);
   
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
   for(i=0; i<limit; i++)  {
      P[i]= (Close[i]-Close[i+1])/Close[i]*100;
   }

   for(i=0; i<limit; i++)  {  //MA
      LP[i]= (MathLog(Close[i])-MathLog(Close[i+1]))/MathLog(Close[i])*100;
   }

   for(i=0; i<limit; i++)  {  //std dev.
      diff[i]= LP[i] - P[i];
   }
/*
   for(i=0; i<limit; i++)  {  //upper band
      UB[i]= Deviations*diff[i] +LP[i]; 
   }
   
   for(i=0; i<limit; i++)  {  //lower band
      LB[i]= LP[i]-(Deviations*diff[i]); 
   }*/
   
   return(0);
}