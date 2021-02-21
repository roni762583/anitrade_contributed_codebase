//+------------------------------------------------------------------+
//|                                          Aharon_Auto_S_R.mq4     |
//|                      Copyright © 2011, Anitani Software Corp. |
//|                                       http://www.anitani.com/ |
//+------------------------------------------------------------------+
// this indicator will detect support resistance levels

#property copyright "Copyright © 2011, Aharon"
#property link      "http://www.anitani.Comment"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red


double Sig[], hc[]; 

double maH0, maHm1, maHp1, maL;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int init()  {
   string short_name;
   short_name="Aharon_Auto_S_R(" + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Sig");
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Sig);
   
   ArrayInitialize(Sig, 0.0);
   IndicatorDigits(Digits);
   return(0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   int    indx;
   double sigH; 
   for(i=limit; i>=0; i--)  {
      maH0  = iMA(NULL, 0, 7, 0, 0, PRICE_HIGH, i); //SMA on High
      maHp1 = iMA(NULL, 0, 7, 0, 0, PRICE_HIGH, i+1); //SMA on High
      maHm1 = iMA(NULL, 0, 7, 0, 0, PRICE_HIGH, i-1); //SMA on High
      
      
      //maL = iMA(NULL, 0, 7, 0, 0, PRICE_LOW, i+1);  //SMA on Low
      
      sigH = 0.0;
      if(maH0>maHm1 && maH0>maHp1)   {
         indx = iHighest(NULL, 0, MODE_HIGH, 10, i);
         sigH = High[indx];
         Sig[indx] = sigH ;
      }
   }
   ArrayCopy(hc, Sig, 0, 0,WHOLE_ARRAY);
   ArraySort(hc, WHOLE_ARRAY, 0, MODE_DESCEND);
   for(i=0; i<ArraySize(hc); i--)   {
      Print("hc[",i,"]=",hc[i]);
   }
   return(0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int deinit()   {
   return(0);
}