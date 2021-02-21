//+------------------------------------------------------------------+
//|                                            A_i_two-bar-slope.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue 

extern int len = 300,  //number of bars to draw 
           nn  = 10;  //number of bars to sum slopes for 

double s[], as[];

int    limit, ii, jj;
double a=1, b=1, c=1, d=1, e=1, f=1, g=1, h=1, i=1, j=1, k=1, l=1, m=1, n=1, o=1, p=1;
double O2, O1, H2, H1, L2, L1, C2, C1;
double s1=0.0, min=0.0000001, max=0.0000001, ff=0.0;
datetime LastBarTime;

int init()  {
   ArrayInitialize(s, 0);
   ArrayInitialize(as, 0);

   IndicatorBuffers(2);
   string short_name;
   short_name = StringConcatenate("A_i_two-bar-slope(nn=",nn,")");
   IndicatorShortName(short_name);

   SetIndexLabel(0, "s");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, s);
   
   SetIndexLabel(1, "as");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, as);

   return(0);
}


int start()  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;  //relevant bars 
   
   for(ii=MathMin(limit,len); ii>=0; ii--) {   //loop over relevant bars 
      
      O2= Open[ii];
      O1= Open[ii+1];
      H2= High[ii];
      H1= High[ii+1];
      L2= Low[ii];
      L1= Low[ii+1];
      C2= Close[ii];
      C1= Close[ii+1];
      
      s1 = (  a*(O2-O1)+b*(O2-H1)+c*(O2-L1)+d*(O2-C1)   //calculate slope in pips/sec.
             +e*(H2-O1)+f*(H2-H1)+g*(H2-L1)+h*(H2-C1)
             +i*(L2-O1)+j*(L2-H1)+k*(L2-L1)+l*(L2-C1)
             +m*(C2-O1)+n*(C2-H1)+o*(C2-L1)+p*(C2-C1)) /
             (Point*(a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p)*Period()*60);
      
      if(Time[ii] != LastBarTime)   {  //on new bar, set: min, max for last nn bars for comparison
         max = 0.0000001;
         min = 0.0000001;
         for(jj=ii+nn; jj>ii; jj--)   {  //establish min, max over last nn bars 
            if(s[jj]>max) max = s[jj];
            if(s[jj]<min) min = s[jj];
         }
         LastBarTime = Time[0];
      }
      
      s[ii] = s1;                  //slopes assigned
      
      if(s1>0) ff = s1/max; //fraction of current slope to historical peak
      if(s1<0) ff = s1/min; //fraction is always positive value
      
      Print("min/max = ", min,"/",max, "   limit = ",limit, "   ii=",ii, "  f=", ff);
      
      for(jj=len; jj>=0; jj--)   { //loop for summing
         if(jj==len) as[jj] =0.0;  //initialize sum to zero at beggining of sum
         else as[jj] = (as[jj+1] + s[jj]) * ff * ff;
      }
         
         //if new s is of same sign as prev. s & sum is not zero prev. continue to sum
      //   else if(((s[ii]>0 && s[ii+1]>0) || (s[ii]<0 && s[ii+1]<0))&&(s1> thrsh*max || s1<thrsh*min)) as[ii] = as[ii+1] + s1;//&&MathAbs(as[ii+1])>0)
        //   else as[ii] = (as[ii+1]/decay;
   }

   return(0);
}

int deinit()  {
   return(0);
}