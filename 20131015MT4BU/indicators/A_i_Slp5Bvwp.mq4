
//+------------------------------------------------------------------+
//|                                       A_i_Slp5Bvwp.mq4.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
/*
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 LightGreen
#property indicator_color6 Yellow
#property indicator_color7 White
*/
//---- external parameters
//extern double BandsDeviations=2.0;
//extern int    BandsPeriod=20;

//vars
//static double ff = 0.0;

//---- buffers
double D[];
/*
double BBu[];
double BBl[];
double Acc[];
double jrk[];
double AllSameSign[];
double sig[];
*/
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_Slp5Bvwp()";//+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"slope");
   /*
   SetIndexLabel(1,"Upper");
   SetIndexLabel(2,"Lower");
   SetIndexLabel(3,"4PtAcc-Gren");
   SetIndexLabel(4,"Jerk-L.Green");
   SetIndexLabel(5,"AllSameSign");
   SetIndexLabel(6,"sig");
*/
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
  /* 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BBu);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BBl);
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Acc);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,jrk);

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,AllSameSign);
   
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,sig);
*/   
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
      D[i]= iCustom(NULL, 0, "A_i_percent_bar_vwma_Typ_gen", 1, i);    
   }
/*   
   for(i=0; i<limit; i++)  {
   BBu[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 1,i);
   BBl[i]=iBandsOnArray(D, 0, BandsPeriod, BandsDeviations, 0, 2,i);
   }
   
   for(i=0; i<limit; i++)  {
      Acc[i]= ((D[i]-D[i+1])+(D[i]-D[i+2])+(D[i]-D[i+3]))/3;
   }
   
   for(i=0; i<limit; i++)  {
      jrk[i]= ((Acc[i]-Acc[i+1])+(Acc[i]-Acc[i+2])+(Acc[i]-Acc[i+3]))/3;
   }

   for(i=0; i<limit; i++)  {
      AllSameSign[i] = 0;
      if(D[i]>0 && Acc[i]>0 && jrk[i]>0) AllSameSign[i] = 0.005;
      if(D[i]<0 && Acc[i]<0 && jrk[i]<0) AllSameSign[i] = -0.005;
   }
   
   for(i=limit; i>=0; i--)   {
      if(AllSameSign[i]==0.005)  ff= 0.005;
      if(AllSameSign[i]==-0.005) ff=-0.005;
      sig[i]=ff;
   }
*/
   return(0);
}
//+------------------------------------------------------------------+