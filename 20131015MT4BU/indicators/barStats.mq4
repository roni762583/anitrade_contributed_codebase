//barStats.mq4
//to check stats if after up bar another in more often, and vise versa

#property copyright "Copyright 2013, Yehuda Software Corp. aharonzbaida@gmail.com "
#property link      "http://www.google.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Green

double upUpCnt[],upDnCnt[], dnUpCnt[], dnDnCnt[];

static int  i  = 9,
            uu = 0,
            ud = 0,
            du = 0,
            dd = 0;

int init()  {
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, upUpCnt);
   SetIndexLabel(0, "upUpCnt");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, upDnCnt);
   SetIndexLabel(1, "upDnCnt");
      
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, dnUpCnt);
   SetIndexLabel(2, "dnUpCnt");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, dnDnCnt);
   SetIndexLabel(3, "dnDnCnt");
   
   string s = "barStats";
   IndicatorShortName(s);
   return(0);
}


int start()   {
   
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars==0) limit=Bars-5; //if first run, give room to prime the ma calc.
   limit=Bars-counted_bars;
   
   if(i==0) return(0);
   
   for(i = limit; i>=0; i--)   {
      if(Close[i+1]>Open[i+1])   {    //up bar at i+1
         if(Close[i]>Open[i]) uu++;
         if(Close[i]<Open[i]) ud++;
      }
      if(Close[i+1]<Open[i+1])   {    //dn bar at i+1
         if(Close[i]>Open[i]) du++;
         if(Close[i]<Open[i]) dd++;
      }   
      upUpCnt[i] = uu;
      upDnCnt[i] = ud;
      dnUpCnt[i] = du;
      dnDnCnt[i] = dd;
   }//close for()
   
   return(0);
}



int deinit()   {

   return(0);
}