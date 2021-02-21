//+------------------------------------------------------------------+
//|                                             Aharon_SimpleEA3.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.metaquotes.net"

extern int WS = 30;           // Window Size in ticks
extern int TW = 5;            // Time Window in sec.
int TS[500];                  // array for time stamps for use with tick window size calc.
double A[500], B[500];        // aray for asks and bids for use with tick window size calc.
int st1, index, wind;          // st1 is start time stamp in stats() func.,   inst is time stamp in TW calc.,   wind is window
int c = 0;                    // counter
int TS4TW[50000];             // array for time stamps for use with time window calc.
double A4TW[500], B4TW[500];  // arays for asks and bids for use with time window calc.
int temp;       ///temp

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()   {  

Print("hello from start()");

   double b = 0.0, a = 0.0;                        //bid, ask
   int ts = 0.0, st = 0.0;                         //time stamp, start time
   bool flag = false;                              //flag to indicate if rates were refreshed at last itteration of while loop
   
   while(true)   {                                 //keep spining
      
      st = GetTickCount();                         //start time stamp
      
      //////////////////////////////////////////////////////////////////////////////////////////////////
      if(RefreshRates())   {                       //if price changed
         ts = GetTickCount();                      //time stamp
         a = StrToDouble(DoubleToStr(Ask,Digits));                                  //assign local vars
         b = StrToDouble(DoubleToStr(Bid,Digits));                                  //assign local vars
         flag = true;                              //flag to indicate if rates were refreshed
         for(int i=0; i<WS; i++)   {               //shift the array elements FIFO
            TS[i] = TS[i+1];
            A[i]  = A[i+1];
            B[i]  = B[i+1];
          //  Print(TS[i],",",A[i]);
         }
         
         TS[WS] = ts;                          //fill array with latest values
         A[WS] = a;
         B[WS] = b;
      }
      ///////////////////////////////////////////////////////////////////////////////////////////////////
      //if(flag) Print("array size for TS is ", ArraySize(TS), " TS[WS] = ", TS[WS]);  //debugging print statement
      flag = false;                           //if not refresh occured, set flag accordingly
      
      //inst = GetTickCount();
      if(st > TS4TW[c])   {
         //Print("inst =", inst, "    TS4TW[c]=", TS4TW[c], "    diff=", inst - TS4TW[c], "   c=", c);
         c++;
         
         TS4TW[c] = st;
         A4TW[c] = StrToDouble(DoubleToStr(Ask,Digits));
         B4TW[c] = StrToDouble(DoubleToStr(Bid,Digits));
         
         wind = (TS4TW[c]-TW*1000);   //window lookback in mSec.
         
         index = ArrayBsearch(TS4TW, wind, MODE_DESCEND);            //index of element of time window start --- debug
         temp = GetTickCount();//-TS4TW[index];
         if(index>0) {
            Print("TS4TWc[",c,"]=", TS4TW[c], "  TS4TWi[",index,"] = ",TS4TW[index]," GetTickCount()= ", temp , "  mSec");
            return(0);
         }
         
         
      }
     
      
      
     
      continue;
   }

   return(0);


}

//////////////////////  stats() func. defined  ////////////////////
string stats(int index)  {
   double bsum = 0.0, asum = 0.0, WinAvgBid = 0.0, WinAvgAsk = 0.0;
   Print("index, c = ", index, " , ", c);
   /*for(int i = c; i>c-index; i--)   {
      bsum = bsum + B4TW[i];       //average bid price in time window
      asum = asum + A4TW[i]; 
   }
   WinAvgBid = bsum/c;            //window average bid 
   WinAvgAsk = asum/c;
   Print("c b4 zeroing = ", c);
   c = 0;
   return("WinAvgBid / WinAvgAsk "+WinAvgBid+" / "+WinAvgAsk+"   index rcvd was "+index);
   */
}
///////////////////////////////////////////////////////////////////












//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()   {
  Print("Calling start() from init()  ");
  start();
/*
   ArrayInitialize(TS, 0);
   ArrayInitialize(A, 0.0);
   ArrayInitialize(B, 0.0);
*/
   return(0);
}



//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
//----
   
//----
   return(0);
}
//+------------------------------------------------------------------+