//+------------------------------------------------------------------+
//|                                  iASI.mq4                  |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
//  Swing Index per JWW Jr. pg. 87

//when this version works good, will replace iASI.mq4, the si[] section will replace iSI.mq4
#property copyright "Copyright 2012, anitani Software Corp. contact@anitani.com "
#property link      "http://www.anitani.com"

#property indicator_buffers 1
#property indicator_color1 White

#property indicator_separate_window

static double as   = 0.0, 
              pas  = 0.0; 
double asi[], si[1000];
static double l = 0.0, L = 0.0, R=0.0;   //used for Limit value calculation

static bool Lcalculated = false;  //flag indicated L (Limit value calculated yet)
int init()  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, asi);
   SetIndexLabel(0,"ASI2");
   SetIndexDrawBegin(0, 0);
   
   ArrayInitialize(si, 0.0);
   ArrayInitialize(asi, NULL);
   
   string s = "ASI2()";
   IndicatorShortName(s);

   return(0);
}



int start()  {
   int limit, i;
   int counted_bars=IndicatorCounted();
     
   if(counted_bars<0)   {Print("Counted Bars<0 Error!");   return(-1);   }     //---- check for possible errors
   if(counted_bars>0) counted_bars--;                                          //---- the last counted bar will be recounted
   limit=Bars-counted_bars;
   
   //set value for L - represents daily LIMIT move, originally from commodities market J. Welles Wilder, Jr.
   //here will be modelled as max pips in range of daily chart, 
   //or, 120% of greatest range bar on the daily chart going back >~1.5 yrs.
   //or 10X ATR(14)
   //or, as 1 increment larger of most significant (left most non-zero) digit
   if(!Lcalculated)  {     //if l has not been set as of yet...
      /* this block works but si's are kinda small
      double ind;
      if(Bars<500) Alert("Possibly not enough bars in chart/history for representing LIMIT value"); 
      for(i=0; i<Bars; i++)    {
         L = MathMax((High[i]-Low[i]), L);
         //alt. relative to current bar chart (iHigh(NULL, PERIOD_D1, i)-iLow(NULL, PERIOD_D1, i))
         //double rng = iHigh(NULL, PERIOD_D1, i) - iLow(NULL, PERIOD_D1, i);
         //if(rng > l) l = rng;   //store greatest range of daily bars in history/chart 
      } //close for loop
      Lcalculated = true;  //set flag on
      string l = DoubleToStr(L, Digits);
      for(i=0; i<=Digits; i++){           //round up most significant digit of range value, this will serve as daily limit move
         if(StringGetChar(l, i)==46 || StringGetChar(l, i)== 48) continue; //ignore char code for period (46), for zero is (48)
         int msd = StrToInteger(StringSubstr(l, i, 1));                    //extract left most non-zero , non-period character, store as int
         msd++;                                                            //increment this most sig. digit by 1
         L = msd/MathPow(10, i-1);                                         //shift decimal to round up range by 1 on most significnt digit 
         break;
      }//close for loop
      */
      for(i=0; i<Bars; i++)   {
         L = MathMax((High[i]-Low[i])/Point, L);
      }
   }//close if(!Lcalculated)  {...
   
   for(i = limit; i > 0; i--)  {
      //index i-is latest (2), while (i+1)-is previous (1) index
      double C2 = Close[i];
      double C1 = Close[i+1];
      double O2 = Open[i];
      double O1 = Open[i+1];
      double H2 = High[i];
      double L2 = Low[i];
      
      double H2C1 = (H2-C1)/Point;
      double L2C1 = (L2-C1)/Point;
      double C1O1 = (C1-O1)/Point;
      double H2L2 = (H2-L2)/Point;
      double C2C1 = (C2-C1)/Point;
      double C2O2 = (C2-O2)/Point;
      
      double r1 = MathAbs(H2C1);
      double r2 = MathAbs(L2C1);
      double r3 = MathAbs(H2L2);
      
      //set value for R
      if(r1>MathMax(r2,r3)) R = MathAbs(H2C1-(0.50*L2C1)+(0.25*C1O1));             //if r1 is greatest of three r's use R(1)
         else if(r2>MathMax(r1,r3)) R = MathAbs(L2C1-(0.50*H2C1)+(0.25*C1O1));     //if r2 is greatest of three r's use R(2)
            else if(r3>MathMax(r1,r2)) R = MathAbs(H2L2+(0.25*C1O1));  //if r3 is greatest of three r's use R(3)
               else if(r1==r2 || r1==r3) R = MathAbs(H2C1-(0.50*L2C1)+(0.25*C1O1));//if r1 is equal to r2 or r3,    use R(1)
                  else if(r2==r3) R = MathAbs(L2C1-(0.50*H2C1)+(0.25*C1O1));        //if r2 is equal to r3,          use R(2)
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //set value for K
      double K = MathMax(r1, r2);
      
      //set value for Numerator - this part dictates sign of SI
      double N = C2C1 + (0.5*C2O2) + (0.25*C1O1);
      
      double ssi;
      if(R<Point || L<Point )   { //catch R=0 devide by zero error
         ssi = 0.0;
      }
      else ssi = MathRound( (50*(N/R)*(K/L)) ); // MathRound(((50*N*K)/(R*L))/Point)
      //if(ssi>100) Print("ssi>100@ ", i);
      si[i] = ssi;
      //Print("ssi=",ssi, " index =", i);
      //if(ssi>=100) Alert("ssi>=100@ ", i, "   on: ", TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
   }   //close for loop 
   
   //calc. for accumulation swing index
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

