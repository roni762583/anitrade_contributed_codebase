//+------------------------------------------------------------------+
//|                                                   A_i_BB_ADX.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
// bolinger bands on ADX directional movement indicator, with accel. on ADX line 

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 White
#property indicator_color6 White
#property indicator_color7 Yellow

//---- external parameters
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;

//---- buffers
double D[];
double BBu[];
double BBl[];
double Acc[];
double BBu1[];
double BBl1[];
double BothAbove[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_BB_ADX("+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ADX");
   SetIndexLabel(1,"Upper");
   SetIndexLabel(2,"Lower");
   SetIndexLabel(3,"ADXaccl");
   SetIndexLabel(4,"ADXacclUpper");
   SetIndexLabel(5,"ADXacclUpper");
   SetIndexLabel(6,"BothAbove");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Acc);

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,BBu1);

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,BBl1);
   
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,BothAbove);

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
      D[i]= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, i);
   }
      
   for(i=0; i<limit; i++)  {
      Acc[i]= ((D[i]-D[i+1])+(D[i]-D[i+2])+(D[i]-D[i+3]))/3;
   }
   
   for(i=0; i<limit; i++)  {
      BBu1[i]=iBandsOnArray(Acc, 0, BandsPeriod, BandsDeviations, 0, 1,i);
      BBl1[i]=iBandsOnArray(Acc, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   for(i=0; i<limit; i++)  {
      BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
      BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }

   for(i=0; i<limit; i++)  {
      if(D[i]>BBu[i] /*&& Acc[i]>BBu1[i]*/) BothAbove[i]= 50.0;
      else BothAbove[i]= -10.0; 
   }

   return(0);
}
//+------------------------------------------------------------------+