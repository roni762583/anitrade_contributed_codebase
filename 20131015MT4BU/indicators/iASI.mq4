//+------------------------------------------------------------------+
//|                                  iASI.mq4                  |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//  Swing Index per JWW Jr. pg. 87
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White
//#property indicator_color2 Green
//#property indicator_color3 Red
//#property indicator_color4 Blue

#property indicator_separate_window

static double as   = 0.0, 
              pas  = 0.0; 
double asi[], si[1000];//, S1[], HBOP[], LBOP[];
static double l = 0.0;
double  L = 0;

int init()  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, asi);
   SetIndexLabel(0,"Accum.Swing.X");
   
   ArrayInitialize(si, 0.0);
   ArrayInitialize(asi, NULL);
   string s = "ASI()";
   IndicatorShortName(s);

   return(0);
}



int start()  {
   int    i, k, counted_bars = IndicatorCounted();
   //---- last counted bar will be recounted
   int limit = Bars - counted_bars;
   if(counted_bars > 0)  limit++;
   
   //set value for L - represents daily LIMIT move, originally from commodities market J. Welles Wilder, Jr.
   //here will be modelled as max pips in range of daily chart //120% of greatest range bar on the daily chart going back >~1.5 yrs.
   if(Bars<500) Alert("Possibly not enough bars in chart/history for representing LIMIT value"); 
   if(l==0.0 && L==0)  { //if l has not been set as of yet...
      for(i=0; i<Bars; i++)    {
         L = MathMax((High[i]-Low[i])/Point, L);//alt. relative to current bar chart (iHigh(NULL, PERIOD_D1, i)-iLow(NULL, PERIOD_D1, i))
         //double rng = iHigh(NULL, PERIOD_D1, i) - iLow(NULL, PERIOD_D1, i);
         //if(rng > l) l = rng;   //store greatest range of daily bars in history/chart 
      }                         //now rng contains maximum range
      //L = 2*rng;              //
      //Alert("L=", L);
      if(L==0)   { 
         Print("L=0!, check daily data");
         l = 0.0;
         return(0);
      }
   }
   
   for(i = limit; i >= 0; i--)  {
      //index i-is latest (2), while (i+1)-is previous (1) index
      double C2 = Close[i];
      double C1 = Close[i+1];
      double O2 = Open[i];
      double O1 = Open[i+1];
      double H2 = High[i];
      double L2 = Low[i];
      double r1 = MathAbs(H2 - C1);//
      double r2 = MathAbs(L2 - C1);//
      double r3 = MathAbs(H2 - L2);
      double R = 9999999.98765;
      
      //set value for R
      if(r1>r2 && r1>r3) R = MathAbs(   (H2-C1) - (0.50*(L2-C1)) + (0.25*(C1-O1))    );
      if(r2>r1 && r2>r3) R = MathAbs(   (L2-C1) - (0.50*(H2-C1)) + (0.25*(C1-O1))    );
      if(r3>r1 && r3>r2) R = MathAbs(   (H2-L2) + (0.25*(C1-O1))                     );
      if(R == 9999999.98765) R = MathAbs(   (H2-C1) - (0.50*(L2-C1)) + (0.25*(C1-O1))    ); //i.e. in the case all are equal, use first option
      
      //set value for K
      double K = MathMax(r1, r2);
      
      //set value for Numerator - this part dictates sign of SI
      double N = (C2-C1) + (0.5*(C2-O2)) + (0.25*(C1-O1));
      double ssi;
      if(R<Point || L<Point || K<Point)   { //catch R=0 devide by zero error
         ssi = 0.0;
      }
      else ssi = MathRound(((50*N*K)/(R*L))/Point); //MathRound((50*(N/R)*(K/L))/Point); // MathRound(((50*N*K)/(R*L))/Point)
      if(ssi>100) Print("ssi>100@ ", i);
      si[i] = ssi;
      
   }   //close for loop 
   for(i = limit; i >= 0; i--)  {   
      if(asi[i]==NULL)  { //initial filling of array with values, will exclude indeces where an asi already exists
         //Print("this worked");
         as = pas + si[i];
         pas = as;
         //Print("si[", i,"]=", si[i]);
         asi[i] = as;
      }
      if(i==0)   { //on last bar, update it, don't keep accumulating again and again
         asi[0] = asi[1] + si[0];
      }
   }   //close for loop 
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

