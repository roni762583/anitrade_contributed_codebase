
//+------------------------------------------------------------------+
//|                                       A_i_N_Bar_Reg_Slope.mq4    |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009, Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- external parameters

extern int    N = 7;                   //number of points for regression
extern int    barsback = 43200;        // barsback must be greater than N, also need to rewrite formula to only recalculate necessary parts as new ticks come in


//vars
//static datetime E = D'2010.06.22 00:00'  ;   // New Year 2010  TimeCurrent
int limit, i, j, k;

double     X[], Y[], XY[], XX[], slp[];

double     SX, SY, SXY, SXX, Prd;                   //Sums over N values

static bool initial = true;

//---- buffers
double Slope[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   Prd = Period();  //
   
   if(Bars<barsback)   { //this is number ofmin. in month 
      barsback = Bars;
      Comment("barsback restricted to available ", barsback," bars");
   }
   else Comment("barsback = ", barsback);
   
   ArrayResize(X, N);
   ArrayResize(Y, N);
   ArrayResize(XY, N);
   ArrayResize(XX, N);
   ArrayResize(slp, barsback);
   
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="A_i_N_Bar_Reg_Slope(barsback="+barsback+", N="+N+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Slope");

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Slope);

//---------------------------------- Initial Calculations ------------------------------------------------------------------
   
   for(i=0; i<barsback; i++)  {                          //main index from left to right
      SX  = 0;                                           //Sum variables, zeroed
      SY  = 0;
      SXY = 0;
      SXX = 0;
      for(j=i+N-1; j>=i; j--)   {                        //j-loop iterates over N, relative to i)
         //Y[j] = (High[j]+Low[j])/2.0;                  //in this case typical price, but can be any timeseries
         SY  = SY + (High[j]+Low[j])/2.0;                //good
         SXY = SXY + ((MathAbs(j-i-N+1)+1)*Prd/1440) * (High[j]+Low[j])/2.0;

         //if(i<3) Print("SXY = ",DoubleToStr(SXY,8));
      }                                                  //closes j for loop

      for(k=1; k<=N; k++)   {                            //loop over N elements, and sum        
         SX  = SX + k*Prd/1440;                           //good, but scale it by dividing by 1440 to get per-day
         SXX = SXX + (k*Prd/1440)*(k*Prd/1440);
      }
      //if(i<0) Print("i, SX, SXX = ", i, ", ", DoubleToStr(SX,8), ", ", DoubleToStr(SXX,8));
      
      slp[i]  =  ((N*SXY) - (SX*SY)) / ((N*SXX) - (SX*SX));
      
   }
   
   return(0);
}





//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()   {
//    ArrayInitialize(FIRMA, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   
//---- check for possible errors
   if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

     
//populate Slope[]
//Slope(b) = (NSXY - (SX)(SY)) / (NSX2 - (SX)2)
   Print("initial = ", initial);
   
   if(initial==true)  {
      ArrayInitialize(Slope, EMPTY_VALUE);
      //Print("Slope[5] = ", Slope[5]);
      for(i=0; i<limit; i++)  {
         Slope[i]  =  slp[i];
      }
      initial = false;
   }                                                        //closes if(initial) scope
   
   if(initial==false)   {
      for(i=0; i<(limit+1); i++)  {                         //main index from left to right
         SX  = 0;                                           //Sum variables, zeroed
         SY  = 0;
         SXY = 0;
         SXX = 0;
   
         for(j=i+N-1; j>=i; j--)   {                        //j-loop iterates over N, relative to i)
            //Y[j] = (High[j]+Low[j])/2.0;                  //in this case typical price, but can be any timeseries
            SY  = SY + (High[j]+Low[j])/2.0;                //good
            SXY = SXY + ((MathAbs(j-i-N+1)+1)*Prd/1440) * (High[j]+Low[j])/2.0;
         }                                                  //closes j for loop

         for(k=1; k<=N; k++)   {                            //loop over N elements, and sum        
            SX  = SX + k*Prd/1440;                           //good, but scale it by dividing by 1440 to get per-day
            SXX = SXX + (k*Prd/1440)*(k*Prd/1440);
         }                                                  //closes k for loop
            Slope[i]  =  ((N*SXY) - (SX*SY)) / ((N*SXX) - (SX*SX));
      }                                                     //closes i for loop
   }   
   return(0);
}                                                           //closes start() func.




//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}

