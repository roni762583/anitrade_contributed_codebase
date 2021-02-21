//+------------------------------------------------------------------+
//|                                                      aEA002b.mq4 |
//|                      Copyright © 2012, Anitani Software          |
//|                                        http://www.anitani.com    |
//+------------------------------------------------------------------+
// This is for building EA that uses price inflections as support resistance automatically and foundation to work thereof
// this version of aEA002.mq uses the standard fractals indicator to identify S / R levels

//recommendation: try to use zigzag indicator for same (try last 10 extremums of each of the large time frames mnth, wk, day, hour, 15min.)
//then rank each level based on TF (higher TF more significant), based on age (recent is more meaningfull), see book for other ranking criteria
//then define a S/R zone of X%, or X pips above and below level
//overlapping zones are additive, thus defining strength of S/R levels

#property copyright "Copyright © 2012, Anitani Software"
#property link      "http://www.anitani.com"

extern int barsBack = 0;

static int    j=0;
static bool   firstRun = true;
static string s;

       double f, fl, fh;
       int    i, limit, k=0;

int start()  {

  // Print("...hi...");

   if(barsBack==0) barsBack = Bars;  //if barsBack is not specified, use whole chart 

   if(firstRun)  {                   //this block of code will run once initially
      
      for(k=barsBack ;k>=0;k--){     //loop over bars 
         fh = iFractals(NULL, 0, MODE_UPPER, k); //get fractal indicator values
         fl = iFractals(NULL, 0, MODE_LOWER, k);
         f  = 0.0;                               //init value
         if(fh!=NULL) f = fh;                    //if fh not empty, set value to fh
         if(fl!=NULL && f==0.0) f = fl;          //if fl is not empty, and f did not get set, store fl in f
         
         if(f!=0)   {                            //if fractal level is present this itteration...
            s = "SR"+DoubleToStr(k,0)  ;         //contruct object name string
            ObjectCreate(s, OBJ_HLINE, 0, Time[k], f);  //create object 
            ObjectSet(s, OBJPROP_COLOR, DarkSlateBlue);
         }
         
      }//close for loop
         
      firstRun = false;
      
   }//close if(firstRun)
 /////////////////////////////////////////////////////////////////////  
   if(!firstRun)  { //this part will run on subsequent incomming ticks
   
   }
   return(0);
} //close start()



int init()  {
   ObjectsDeleteAll();
   firstRun = true;
   return(0);
}//close init()



int deinit()   {
   firstRun = true;
   ObjectsDeleteAll();
   j=0;
   return(0);
}

