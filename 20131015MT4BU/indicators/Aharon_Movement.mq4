//+------------------------------------------------------------------+
//|                                              Aharon_Movement.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Yellow
//#property indicator_color3 Red

double mov, ubb, lbb;


//---- buffers
double M[], MV[];//, MS[];


//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int init()   {
   IndicatorBuffers(2);//3);
                              //---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name = "Aharon_Momevent(" + ")";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"Signal");
   SetIndexLabel(1,"Signal2");
   //SetIndexLabel(2,"Signal3");
                                  //---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
  // SetIndexStyle(2,DRAW_LINE);
   
   SetIndexBuffer(0,M);
   SetIndexBuffer(1,MV);
//   SetIndexBuffer(2,MS);

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
      
      
      
   for(i=limit+1; i>=0; i--)  {  //may need <=
       mov = MathAbs(Close[i] - Close[i+1]);
       M[i] = M[i+1] + mov;
   }
   
   for(i=limit+1; i>=0; i--)  {  //
      double fs = 0.0, d01 = 0.0, d12 = 0.0, d02 = 0.0;
      double fsa =1.0, fsb=1.0, fsc=1.0;
      d01 = M[i] - M[i+1];
      d12 = M[i+1] - M[i+2];
      d02 = d01 + d12;
      fs = ((fsa*d01 + fsb*d12 + fsc*d02)/(fsa + fsb + fsc)) * MathPow(10,Digits);
      MV[i] = fs;
   }
   /*
   for(i=0; i<limit; i++)   {
      double fs = 0.0, d01 = 0.0, d12 = 0.0, d02 = 0.0;
      double fsa =1.0, fsb=1.0, fsc=1.0;
      
      d01 = M[i] - M[i-1];  
      d12 = M[i-1] - M[i-2];
      d02 = d01 + d12;   //delta between last bar, and two-bars-ago (firstbar and thirdbar)
      fs = ((fsa*d01 + fsb*d12 + fsc*d02)/(fsa + fsb + fsc)) * MathPow(10,Digits);  //weighed average to quantify slope over last three bars 
      MV[i] = -fs;
   }*/
   /*
   for(i=0; i<limit; i++)   {
      MS[i] = MathAbs(Close[i]-Close[i+1]) * MathPow(10,Digits);
   }*/
}