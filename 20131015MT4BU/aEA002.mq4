//+------------------------------------------------------------------+
//|                                                       aEA002.mq4 |
//|                      Copyright © 2012, Anitani Software          |
//|                                        http://www.anitani.com    |
//+------------------------------------------------------------------+
// This is for building EA that uses price inflections as support resistance automatically and foundation to work thereof

#property copyright "Copyright © 2012, Anitani Software"
#property link      "http://www.anitani.com"

double bins[],hpa[600000],lpa[600000];

int limit;

static double lsh, lsl, rn, rx;//last sig. high/low 
static int    j=0, hti=0, k;
static bool   firstRun = true;
static string s;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()  {
   limit=Bars-2;
   ObjectsDeleteAll();
   
   
   //Print("hi from init()");  //ok
   /*
   for(int i=limit; i>=0; i--)   {
      
      if(High[i]>High[i+1])  {
         lsh = High[i];
       //  Print("..", lsh, "   ", i);
      }
      if(High[i]<High[i+1])  {
         HiTm[hti] = Time[i+1];//!!!!!!!why dosntHiTm[] not store datetime ???
         hti++;
         lsh = 0.0;
     //    Print("hti=", hti, "  HiTm[hti] ", TimeToStr(HiTm[hti], TIME_DATE|TIME_MINUTES));
      }
   }//close for loop
   */
   //hti=0;
   //start();
   return(0);
}//close init()


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()   {
   firstRun = true;
   ObjectsDeleteAll();
   j=0;
   //WindowPriceMax() - WindowPriceMin() 
   
   
   return(0);
}


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()  {
   
   double ranking;
   
   if(firstRun)  {  //this part is run initially
     // Print("limit=",limit);
      for(k=limit;k>0;k--){
         hpa[k]=High[k];
         lpa[k]=Low[k];
      }//close for loop
      
      for(int i =limit-2; i>0; i--)  {
         //Print("hi from start  ", i);
         if( High[i+1]<High[i] && High[i]>High[i-1] && 
             High[i]>High[i+2] && High[i]>High[i-2]    )   {
            s = DoubleToStr(j,0) + "high";
            //ObjectCreate(s, OBJ_HLINE, 0, Time[i], High[i]);
            //ObjectSet(s, OBJPROP_COLOR, OrangeRed);
           // ranking = (   10000/((TimeCurrent() - Time[i])/(3600*24))  );
            if(ranking<rn) rn=ranking;
            if(ranking>rx) rx=ranking;
            //Print(MathRound((WindowPriceMax()-WindowPriceMin())/(Point*200)));//divisions in chart of 20 pips each
            ObjectCreate(s, OBJ_TEXT, 0, Time[0], High[i]); //draw an up arrow
            ObjectSetText(s, DoubleToStr(ranking, 8), 10, "Times New Roman", Green);
           // ObjectSet(s, OBJPROP_STYLE, STYLE_SOLID);
           // ObjectSet(s, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
           // ObjectSet(s, OBJPROP_COLOR,Yellow);
            
            j++;
         } //close if()
         
         if( Low[i+1]>Low[i] && Low[i]<Low[i-1] &&
             Low[i]<Low[i+2] && Low[i]<Low[i-2]        )   {
         
            s = DoubleToStr(j,0) + "low";
            ObjectCreate(s, OBJ_HLINE, 0, Time[i], Low[i]);
            ObjectSet(s, OBJPROP_COLOR, Blue);
            j++;
         } //close if()
         

      }//close for loop
      
      firstRun = false;
   }
   
   
   if(!firstRun)  { //this part will run on subsequent incomming ticks
      Print("hpa min =",ArrayMinimum(hpa));
      //Print("tick...");
      
   }
   return(0);
}