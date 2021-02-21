// A_i_Hi_range_and_vol.mq4
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Blue
 
double s[];

int    limit, i;
double s1, s2;


int init()  {
   IndicatorBuffers(1);
   string short_name;
   short_name = "A_i_Hi_range_and_vol";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0, "s");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, s);
   
   return(0);
}

int start()  {
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=0; i<limit; i++)  {
      s1 = 0.0;
      s2 = 0.0;
      if( iCustom(NULL, 0, "Aharon_Bands_on_Volume",    2.0, 20,  0, i) >
          iCustom(NULL, 0, "Aharon_Bands_on_Volume",    2.0, 20,  1, i)   )  s1 = 1.0;
       
      if( iCustom(NULL, 0, "Aharon_Bands_on_ATR",    2.0, 20, 5,    0, i) >
          iCustom(NULL, 0, "Aharon_Bands_on_ATR",    2.0, 20, 5,    1, i)   )  s2 = 1.0;
      
      if( s1 == 1.0 && s2 ==1.0 && Open[i]<Close[i]) s[i] =  1.0;
         else if( s1 == 1.0 && s2 ==1.0 && Open[i]>Close[i]) s[i] =  -1.0;
            else  s[i] =  0;
      
   }

   return(0);
}

int deinit()  {
   return(0);
}