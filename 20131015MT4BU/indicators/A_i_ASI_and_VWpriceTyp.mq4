//+------------------------------------------------------------------+
//|                                       A_i_ASI_and_VWpriceTyp.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

//---- external parameters
extern int barsback=1000;


//---- buffers
double ASI[];
double VWP[];

int init()  {   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_ASI_and_VWpriceTyp.mq4("+barsback+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ASI");
   SetIndexLabel(1,"VWP");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ASI);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,VWP);
   
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
      ASI[i]=iCustom(NULL, 0, "A_i_WWJ_ASI3", barsback, 2, i);  
      VWP[i]=iCustom(NULL, 0, "A_i_vwma_Prc_Typ_gen", 0, i)*100;
   }
      return(0);
}
//+------------------------------------------------------------------+//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}

