//+------------------------------------------------------------------+
//|                                          Aharon_7_Bar_Signal.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Pink
#property indicator_color5 Orange
//---- buffers
double Slope[];
double Signal[];
double Signal2[]; //this is difference of top 2 lines, needs to equal =0 to open and hold a position
double Signal3[]; //this is if both increasing or decreasing
double Signal4[]; //this is if sig2 is 0, and Sig3 is on, (+)==>Buy, (-)==>Sell.

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,Slope);
   
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Signal);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Signal2);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Signal3);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Signal4);
//----

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
   int    i, slope_sum, delta, counted_bars=IndicatorCounted();
   int start_bar = Bars - 8;
   int period = Period();
//----
   for(i=start_bar; i>=0; i--) { 
     //-----
     //slope_sum = 0;
     Slope[i]= ((((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+7]+Low[i+7]+Open[i+7]+Close[i+7])/4)) / period*7) +
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+6]+Low[i+6]+Open[i+6]+Close[i+6])/4)) / period*6) + 
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+5]+Low[i+5]+Open[i+5]+Close[i+5])/4)) / period*5) +
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+4]+Low[i+4]+Open[i+4]+Close[i+4])/4)) / period*4) +
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+3]+Low[i+3]+Open[i+3]+Close[i+3])/4)) / period*3) +
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+2]+Low[i+2]+Open[i+2]+Close[i+2])/4)) / period*2) +     
                 ((((High[i]+Low[i]+Open[i]+Close[i])/4) - ((High[i+1]+Low[i+1]+Open[i+1]+Close[i+1])/4)) / period*1))/7);
               
     ////// Print("period", period);
 
     //for(delta=7; delta>0; delta--) {
       //----
       //slope_sum=slope_sum+( ( ((High[i]+Low[i]+Open[i]+Close[i])/4)-((High[i+delta]+Low[i+delta]+Open[i+delta]+Close[i+delta])/4) ) / ( delta*period ) );
       //----
       //Print("Slope[i]=",Slope[i],"    delta*period=",delta*period);
     //}
     //Slope[i]=slope_sum/7;
     //slope_sum = 0;
     //-----
   }
   for(i=start_bar; i>=0; i--) {
     if(Slope[i]<Slope[i+1] && Slope[i]<=Slope[i+2]) //turned down
     {
       Signal[i]=0-MathAbs(Slope[i]);
     }
     else if (Slope[i]>Slope[i+1] && Slope[i]>=Slope[i+2]) //turned up
     {
       Signal[i]=MathAbs(Slope[i]);
     }
     else Signal[i]=0;
   }
   //////////////////////////////////////////////////////Signal2  Green
   for(i=start_bar; i>=0; i--) {
     Signal2[i]=MathAbs(Signal[i]-Slope[i]);
   }
   //////////////////////////////////////////////////////Signal3  Pink
   for(i=start_bar; i>=0; i--) {
     if(Slope[i]>Slope[i+1] && Signal[i]>Signal[i+1]) //both slope and signal are increasing
     {
       Signal3[i]=0.0010; //this level is ON
     }
     else if(Slope[i]<Slope[i+1] && Signal[i]<Signal[i+1]) //both slope and signal are decreasing
     {
       Signal3[i]=-0.0010; //this level is ON
     }
   }
   ////////////////////////////////////////////////////Signal4  Orange
   for(i=start_bar; i>=0; i--) {
     if(Signal2[i]==0 && Signal3[i]==0.0010) //Sig2=0 (Green) & Sig3=.001(Pink) ==> Buy (if no open position.)
     {
       Signal4[i] = 0.01;
     }
     else if(Signal2[i]==0 && Signal3[i]==-0.0010) //Sig2=0 (Green) & Sig3=-.001(Pink) ==> Sell (if no open position.)
     {
       Signal4[i] = -0.01;
     }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+