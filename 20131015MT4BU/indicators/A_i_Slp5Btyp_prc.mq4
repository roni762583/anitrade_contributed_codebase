
//+------------------------------------------------------------------+
//|                                       A_i_Slp5Btyp_prc.mq4       |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- external parameters
//extern double BandsDeviations=2.0;
//extern int    BandsPeriod=20;

//vars
//static double ff = 0.0;
double tp, tp1, tp2, tp3, tp4, slp1, slp2, slp3, slp4;
double a1 = 1, 
       a2 = 1,
       a3 = 1,
       a4 = 1;

//---- buffers
double D[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_Slp5Btyp_prc()";//+BandsDeviations+", "+BandsPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"slope");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);

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
      tp  = (High[i]-Low[i])/2;  //tp is typical price 
      tp1 = (High[i+1]-Low[i+1])/2;
      tp2 = (High[i+2]-Low[i+2])/2;
      tp3 = (High[i+3]-Low[i+3])/2;
      tp4 = (High[i+4]-Low[i+4])/2;
      
      slp1 = (tp-tp1)/ Period();
      slp2 = (tp-tp2)/(2*Period());
      slp3 = (tp-tp3)/(3*Period());
      slp4 = (tp-tp4)/(4*Period());
      
      D[i] = (a1*slp1 + a2*slp2 + a3*slp3 +a4*slp4)/(a1+a2+a3+a4);
            
   }

   return(0);
}
//+------------------------------------------------------------------+