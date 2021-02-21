//+------------------------------------------------------------------+
//|                                                 Aharon_Trend.mq4 |
//|                                         Copyright © 2009, Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Yellow

//---- buffers
double Highs[];
double Lows[];
double Graph[];
double Continuation[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Highs);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Lows);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Graph);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Continuation);
   
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
   int    i, limit;
   int    counted_bars=IndicatorCounted(); //number of bars not changed after indicator last launched
   double d;
//----
   if(counted_bars<0) return(-1); // check for possible errors

   if(counted_bars>0) counted_bars--;  //the last counted bar will not be recounted
   limit = Bars - counted_bars;        //total bars minus changed bars minus one
   
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=limit;i++)
        {
         Highs[Bars-i]=EMPTY_VALUE;
         Lows[Bars-i]=EMPTY_VALUE;
         Graph[Bars-i]=EMPTY_VALUE;
         Continuation[Bars-i]=EMPTY_VALUE;
        }


//LOWS CALCULATED
   for(i=Bars-1; i>0; i--)
      {
      if(Low[i]>Low[i+1])        // higher low
        {
        Lows[i]=Low[i];          //
        }
      else if(Low[i]<Low[i+1])   // lower low
        {
   //     Lows[i]=0;               //
      //  Continuation[i]=Low[i];
        Highs[i]=High[i];
        }
      else if(Low[i]==Low[i+1])   // equal lows
        {
    //    Lows[i]=0;
        Continuation[i]=Low[i];
        }
      else Print("ERROR IN LOWS");
      
      
//HIGHS CALCULATED
      if(High[i]>High[i+1])      // higher high
        {
        //Highs[i]=0;              //
     //   Continuation[i]=High[i];
        Lows[i]=Low[i];
        }
      else if(High[i]<High[i+1]) // lower high
        {
        Highs[i]=High[i];        //
        }
      else if(High[i]==High[i+1]) // equal highs
        {
        //  Highs[i]=0;              //
        Continuation[i]=High[i];
        }
      else Print("ERROR IN HIGHS");
    
//GRAPH CALCULATED
//      if(Lows[i]>Highs[i])
//        {
//        Graph[i]=Lows[i];
//        }   
//      else if(Highs[i]>Lows[i])
//        {
        Graph[i]=(High[i]+Low[i])/2;
//        }
      /*
      //Make time series array of highs
      Highs[i] = MathMax(Highs[i+1], High[i]);// Highs[] is equal to the higher of current high and previous High
      
      //Make time series array of lows
      Lows[i]= MathMax(Lows[i+1], Low[i]);  */
      
      }
      
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+