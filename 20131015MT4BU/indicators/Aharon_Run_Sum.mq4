//+------------------------------------------------------------------+
//|                                               Aharon_Run_Sum.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//#property indicator_color2 Blue
//---- buffers
double ExtMapBuffer1[];
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//   SetIndexStyle(1,DRAW_LINE);
//   SetIndexBuffer(1,ExtMapBuffer2);
//----
 


   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+




int start()
  {
 
//----
   
  int    i, limit;
   int    counted_bars=IndicatorCounted(); //number of bars not changed after indicator last launched
   double d;


if(counted_bars<0) return(-1); // check for possible errors

   if(counted_bars>0) counted_bars--;  //the last counted bar will not be recounted
   limit = Bars - counted_bars;        //total bars minus changed bars minus one
   
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=limit;i++)
        {
         ExtMapBuffer1[Bars-i]=0;
      //   ExtMapBuffer2[Bars-i]=EMPTY_VALUE;
        }
   
  
//----
   for(i=1;i<limit;i++)
     {
       if(iMA(NULL,0,7,0,0,1,i)>iMA(NULL,0,7,0,0,1,i+1))
       {
         ExtMapBuffer1[i]=ExtMapBuffer1[i+1]+0.1;  //ExtMapBuffer2[i];
       }
       else if(iMA(NULL,0,7,0,0,1,i)<iMA(NULL,0,7,0,0,1,i+1))
       {
         ExtMapBuffer1[i]=ExtMapBuffer1[i+1]-0.1; //ExtMapBuffer2[i];
       }
    } 
      
    
    
//----
   return(0);
  }
//+------------------------------------------------------------------+