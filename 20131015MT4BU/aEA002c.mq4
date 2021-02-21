//+------------------------------------------------------------------+
//|                                                      aEA002c.mq4 |
//|                      Copyright © 2012, Anitani Software          |
//|                                        http://www.anitani.com    |
//+------------------------------------------------------------------+
// This is for building EA that uses price inflections as support resistance automatically and foundation to work thereof
// this version of aEA002.mq uses the standard fractals indicator to identify S / R levels

//recommendation: try to use zigzag indicator for same (try last 10 extremums of each of the large time frames mnth, wk, day, hour, 15min.)
//then rank each level based on TF (higher TF more significant), based on age (recent is more meaningfull), see book for other ranking criteria
//then define a S/R zone of X%, or X pips above and below level
//overlapping zones are additive, thus defining strength of S/R levels

// store highs and lows of zigzag indicator in separate arrays for referencing questions like "is current price above prev. zigzag high?"
// do like an ASI based on breaking through prev. market reversal values

#property copyright "Copyright © 2012, Anitani Software"
#property link      "http://www.anitani.com"

extern int barsBack = 0;

static int    j=0;
static bool   firstRun = true;
static string s;
static double z = 0.0, zp=0.0;

       double   z15levels[15], z60levels[15], z1440levels[15], z10080levels[15], z43200levels[15]; //levels are zigzag prices
       datetime z15times[15],  z60times[15],  z1440times[15],  z10080times[15],  z43200times[15];  //timestamp of bar 
       bool     z15HL[15],     z60HL[15],     z1440HL[15],     z10080HL[15],     z43200HL[15];     //  in dicates maxima=true, and Minima=false
                
       int    i, limit, k=0, TF;
      

int start()  {
   if(firstRun)  {                        //this block of code will run once initially
      for(i=0; i<=4; i++)   {             // loop over TF's
         
         if(i==0)  {                      // first case 15min. TF
               TF=15;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z15levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z15HL[j] = true;   // if maxima
                     if(z<zp) z15HL[j] = false;  // if minima
                     z15times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               }  //closes for(k=0...
         } //closes if(i==0...
         j=0;
         zp = 0.0;
         
         if(i==1)  {                      // first case 60 min. TF
               TF=60;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z60levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z60HL[j] = true;   // if maxima
                     if(z<zp) z60HL[j] = false;  // if minima
                     z60times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;         
         
         if(i==2)  {                      // first case 60 min. TF
               TF=1440;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z1440levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z1440HL[j] = true;   // if maxima
                     if(z<zp) z1440HL[j] = false;  // if minima
                     z1440times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;
         
         if(i==3)  {                      // first case 60 min. TF
               TF=10080;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z10080levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z10080HL[j] = true;   // if maxima
                     if(z<zp) z10080HL[j] = false;  // if minima
                     z10080times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;         
         
         if(i==4)  {                      // first case 60 min. TF
               TF=43200;
               for(k=0; k<Bars; k++)   {  //loop over Bars
                  zp = z;
                  z  = iCustom(NULL, TF, "ZigZag", 12, 5, 3, 0, k);
                  if(z!=NULL) {   //if z has a value
                    Print("z=", z, ",  j=", j, ",  k=", k);
                     z43200levels[j] =  z;  //j is index for arrays 
                     if(z>zp) z43200HL[j] = true;   // if maxima
                     if(z<zp) z43200HL[j] = false;  // if minima
                     z43200times[j] = iTime(NULL, TF, k); 
                     j++;
                  } //closes if(z!=NULL)
                  if(j>10) break;
               } //closes for(k=... loop
         } //closes if(i==0...
         j=0;
         zp = 0.0;
                
      }//close for loop
         
      firstRun = false;
      
   }//close if(firstRun)

   if(!firstRun)  {                                                   //this part will run on subsequent incomming ticks
      for(k=0; k<11; k++)   {
               s = "SR15_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z15levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Blue);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR60_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z60levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Green);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR1440_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z1440levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Yellow);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR10080_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z10080levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Red);
      }  //close for k
      for(k=0; k<11; k++)   {
               s = "SR43200_"+DoubleToStr(k,0)  ;                        //contruct object name string
               ObjectCreate(s, OBJ_HLINE, 0, Time[k], z43200levels[k]);  //create object 
               ObjectSet(s, OBJPROP_COLOR, Purple);
      }  //close for k
      
   }//close if !firstRun
   
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

