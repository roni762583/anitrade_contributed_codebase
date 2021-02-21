//+------------------------------------------------------------------+
//|                                                    ASI-myMod.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TST Software Corp."
#property link      "http://www.google.co.il/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Gold

static bool firstDraw = true;

extern double T = 300.0;

double ExtMapBuffer1[];
double SIBuffer[];

int init()   {
   //---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexLabel(0, "Accumulation Swing Index");
   SetIndexBuffer(1, SIBuffer);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);

   return(0);
}

  
  
int start()   {
   int counted_bars = IndicatorCounted();
   int i, limit;
   double R, K, TR, ER, SH, Tpoints;
   if(counted_bars == 0) limit = Bars - 1;
   if(counted_bars > 0) limit = Bars - counted_bars;
   
   Tpoints = T*MarketInfo(Symbol(), MODE_POINT);
   
   for(i = limit; i >= 0; i--)   {
      
      TR = iATR(Symbol(), 0, 1, i);
      
      if(Close[i+1] >= Low[i] && Close[i+1] <= High[i]) ER = 0; 
         else   {
            if(Close[i+1] > High[i]) ER = MathAbs(High[i] - Close[i+1]);
            if(Close[i+1] < Low[i])  ER = MathAbs(Low[i] - Close[i+1]);
         }
      
      K = MathMax(MathAbs(High[i] - Close[i+1]), MathAbs(Low[i] - Close[i+1]));
      SH = MathAbs(Close[i+1] - Open[i+1]);
      R = TR - 0.5*ER + 0.25*SH;
      
      if(R == 0) SIBuffer[i] = 0;
         else SIBuffer[i] = 50*(Close[i] - Close[i+1] + 0.5*(Close[i] - Open[i]) + 0.25*(Close[i+1] - Open[i+1]))*(K / Tpoints) / R;
      ExtMapBuffer1[i] = ExtMapBuffer1[i+1] + SIBuffer[i];
   }//close for loop
   
   /// delete and draw objects 
   if(limit>2 && firstDraw)   {
      firstDraw = false;
      ObjectsDeleteAll();
      for(i = 10; i >= 0; i--)   {
         double emb  = ExtMapBuffer1[i];
         double emb1 = ExtMapBuffer1[i+1];
         double emb2 = ExtMapBuffer1[i+2];
         
         //valley in ASI
         if(emb1<emb && emb1<emb2)   {
            //v-line
            string on = "vl1"+i;
            ObjectCreate(on, OBJ_VLINE, 0 , Time[i+1], 0.0);
            ObjectSet(on, OBJPROP_COLOR, Blue);
            //h-line
            string oh = "hl1"+i;
            ObjectCreate(oh, OBJ_HLINE, 1 , Time[i+1], Low[i+1]); //emb1
            ObjectSet(oh, OBJPROP_COLOR, Blue);
         }//close if scope
        
         //Peak in ASI
         if(emb1>emb && emb1>emb2)   {
            string ob = "vl2"+i;
            ObjectCreate(ob, OBJ_VLINE, 0 , Time[i+1], 0.0);
            ObjectSet(ob, OBJPROP_COLOR, Red);
            //h-line
            string ok = "hl2"+i;
            ObjectCreate(ok, OBJ_HLINE, 1 , Time[i+1], High[i+1]); //emb1
            ObjectSet(ok, OBJPROP_COLOR, Red);
         }//close if scope
      }//close for loop
   }//close if scope
      return(0);
}//close start func.



int deinit()  {
   return(0);
}

