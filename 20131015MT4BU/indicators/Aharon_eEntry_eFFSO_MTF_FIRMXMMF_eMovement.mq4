//+------------------------------------------------------------------+
//|                   Aharon_eEntry_eFFSO_MTF_FIRMXMMF_eMovement.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
//this to combine ordered slope with firma X MAMA with eMovement as entry signal

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

//////////////// params for s1: Aharon_eFFSO_MTF  ///////
extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern double ThldDecimal = 1.0;
extern int    TF1         = 0;
extern int    TF2         = 0;
extern int    TF3         = 0;
//////////////////////////////////////////////////

////////////////  params for s2: Aharon_FIRMXMMF  ///////
extern int    TF1m = 0;       
extern int    Period1 = 20;
extern int    Taps1   = 21;     //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 2;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 2;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
///////////////////////////////////////////////////////////////

////////////////  params for s3: Aharon_eMovement /////////////
extern double Threshold = 12.0;
///////////////////////////////////////////////////////////////

double s1, s2, s3;

//---- buffers
double S[];



//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   //IndicatorBuffers(2);//3);
   IndicatorBuffers(1);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_eEntry(" + Threshold + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Signal");
                                  //---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   
   SetIndexBuffer(0,S);


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
      

   for(i=0; i<limit; i++)   {
      s1 = iCustom(NULL, 0, "Aharon_eFFSO_MTF",    BandsDeviations, BandsPeriod, ThldDecimal, TF1, TF2, TF3    , 3, i);  // ==0, 1.0, -1.0
/*extern double BandsDeviations=2.0;
extern int    BandsPeriod=20;
extern double ThldDecimal = 1.0;
extern int    TF1         = 5;
extern int    TF2         = 5;
extern int    TF3         = 15;
*/
      s2 = iCustom(NULL, 0,"Aharon_FIRMXMMF",       TF1m, Period1, Taps1, Window1, MA1Period, MA1shift, MA1method, MA2Period, MA2shift, MA2method,
                   3, i);    //  == 1.0, -1.0
/*////////////////  params for s2: Aharon_FIRMXMMF  ///////
extern int    TF1m = 0;       
extern int    Period1 = 20;
extern int    Taps1   = 21;     //must be odd number
extern int    Window1   = 4;

extern int    MA1Period = 2;
extern int    MA1shift = 0;
extern int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA

extern int    MA2Period = 2;
extern int    MA2shift = 0;
extern int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
//////////////////////////////////////////////////////////*/

      s3 = iCustom(NULL, 0, "Aharon_eMovement",     Threshold,    0, i);   // == 1.0, 0.0
/*//////////////  params for s3: Aharon_eMovement /////////////
extern double Threshold = 12.0;
/////////////////////////////////////////////////////////////*/
      
      S[i] = 0.0;
      if(s1 == 1.0 && s2 == 1.0 && s3 == 1.0)   S[i] = 1.0;
      if(s1 == -1.0 && s2 == -1.0 && s3 == 1.0) S[i] = -1.0;

   }
   

}