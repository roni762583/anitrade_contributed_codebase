//+------------------------------------------------------------------+
//|                                          Aharon_4SMA_Ordered.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
/*/---- input parameters
extern int       SMA5=12;
extern int       SlowEMA=26;
extern int       SignalSMA=9;*/
//---- buffers
double SMA5[];
double SMA15[];
double SMA30[];
double SMA60[];

//---- indicator buffers
double RedBuffer[];
double BlueBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(6);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RedBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BlueBuffer);
   
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
   int limit, i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

// Set SMA array values
   for(i=0; i<limit; i++)  {
      SMA5[i] =iMA(NULL,0,5,0,0,PRICE_OPEN,i);
      SMA15[i]=iMA(NULL,0,15,0,0,PRICE_OPEN,i);
      SMA30[i]=iMA(NULL,0,30,0,0,PRICE_OPEN,i);
      SMA60[i]=iMA(NULL,0,60,0,0,PRICE_OPEN,i);
   }
      
   // Set graph array values
   for(i=0; i<limit; i++)  
   {  //going down
      if((iMA(NULL,0,5,0,0,PRICE_OPEN,i))<(iMA(NULL,0,15,0,0,PRICE_OPEN,i)) && 
         (iMA(NULL,0,15,0,0,PRICE_OPEN,i))<(iMA(NULL,0,30,0,0,PRICE_OPEN,i)) && 
         (iMA(NULL,0,30,0,0,PRICE_OPEN,i))<(iMA(NULL,0,60,0,0,PRICE_OPEN,i))) 
      {
         BlueBuffer[i]=-1;
      } //going up
      else 
      if((iMA(NULL,0,5,0,0,PRICE_OPEN,i))>(iMA(NULL,0,15,0,0,PRICE_OPEN,i)) && 
         (iMA(NULL,0,15,0,0,PRICE_OPEN,i))>(iMA(NULL,0,30,0,0,PRICE_OPEN,i)) && 
         (iMA(NULL,0,30,0,0,PRICE_OPEN,i))>(iMA(NULL,0,60,0,0,PRICE_OPEN,i))) 
      {
         BlueBuffer[i]=1;
      }
      else 
      { //going neither up, nor down
         BlueBuffer[i]=0;
      }
      
      //RedBuffer for difference btween SMA's
      
      if(    MathMax(    MathMax(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMax(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ) -
             MathMin(    MathMin(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMin(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    )
                          
                            
                    >                               //increasing
                            
                            
             MathMax(    MathMax(      (iMA(NULL,0,5,0,0,PRICE_OPEN,i-1)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i-1))   
                                ),  
                         MathMax(      (iMA(NULL,0,30,0,0,PRICE_OPEN,i-1)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i-1))   
                                )   
                    ) -
             MathMin(    MathMin(      (iMA(NULL,0,5,0,0,PRICE_OPEN,i-1)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i-1))   
                                ),  
                         MathMin(      (iMA(NULL,0,30,0,0,PRICE_OPEN,i-1)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i-1))   
                                )   
                    ) 
      )                   
      {
         RedBuffer[i]=1;/*((MathMax(    MathMax(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMax(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ) -
             MathMin(    MathMin(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMin(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ))/iATR(NULL, 0, 30, i));*/
      }
      
      else 
      if(    MathMax(    MathMax(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMax(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ) -
             MathMin(    MathMin(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMin(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    )
                          
                            
                    <                               //decreasing
                            
                            
             MathMax(    MathMax(      (iMA(NULL,0,5,0,0,PRICE_OPEN,i-1)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i-1))   
                                ),  
                         MathMax(      (iMA(NULL,0,30,0,0,PRICE_OPEN,i-1)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i-1))   
                                )   
                    ) -
             MathMin(    MathMin(      (iMA(NULL,0,5,0,0,PRICE_OPEN,i-1)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i-1))   
                                ),  
                         MathMin(      (iMA(NULL,0,30,0,0,PRICE_OPEN,i-1)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i-1))   
                                )   
                    ) 
      )                   
      {
         RedBuffer[i]=-1;/*((MathMax(    MathMax(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMax(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ) -
             MathMin(    MathMin(     (iMA(NULL,0,5,0,0,PRICE_OPEN,i)), (iMA(NULL,0,15,0,0,PRICE_OPEN,i))   
                                ),  
                         MathMin(     (iMA(NULL,0,30,0,0,PRICE_OPEN,i)),(iMA(NULL,0,60,0,0,PRICE_OPEN,i))   
                                )   
                    ))     );*/
      }
      else 
      {
         RedBuffer[i]=0;
      }
   }                                                                 
   return(0);
  }