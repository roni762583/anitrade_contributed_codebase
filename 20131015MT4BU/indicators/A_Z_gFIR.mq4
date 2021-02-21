//+------------------------------------------------------------------+
//|                                                     A_Z_gFIR.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_separate_window

// Global Scope Variables


//---- buffers
double P[];
double C[];




//---- input parameters
extern int       Taps=21;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()   {
   //IndicatorBuffers
   IndicatorBuffers(2);
                     
   string short_name;
   short_name = "A_Z_gFIR(" + Taps + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0,"Signal");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,P);

   SetIndexLabel(1,"Signal");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,C);
   
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
   int limit, i;
   int    counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1); //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(i=0; i<limit; i++)   {   //WEIGHTED PRICE    BLUE
      P[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4 ;
   }
   for(i=0; i<limit; i++)   {   //       YELLOW
      C[i] = W[i]*P[i];
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+