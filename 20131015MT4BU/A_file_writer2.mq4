//+------------------------------------------------------------------+
//|                                               A_file_writer2.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

int handle;  //handle for file
int err;     //error 
static int tc, Ptc, i;
double ask, bid, Bvel, Avel;
static datetime time, LastSec, dif;
static double Pask, Pbid, AskVelSum, BidVelSum;


int init()   {
   LastSec = TimeCurrent();
   
   string filename = StringConcatenate("fw2_", Symbol(), ".", TimeToStr(TimeCurrent(),TIME_DATE), ".", TimeCurrent(), ".csv");
   handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
 
   err = FileWrite(handle, "Date", "Time", "Ask", "AskVelSum", "Bid", "BidVelSum" );
   Print("err=",err);
   if(handle<1)   {
     Print("File ", filename, " error, the last error is ", GetLastError());
     return(false);
   }
   else Print("handle = ", handle);
    
   return(0);
}


int start()   {   
   if(handle>0)   {
     tc   = GetTickCount();                                // millisec timestamp
     time = TimeCurrent();                                 // last server time in sec. since epoch
     bid = Bid;                                            // bid at present
     ask = Ask;                                            // ask at present
     
     //now compare if last tick is within 'last' whole sec.
     if(time == LastSec)   {                               // if it is w/in last sec. // add velocities to sum of velocities in this sec.
        Avel = (ask - Pask)/(tc-Ptc);                      // intant. ask vel. calc.
        Bvel = (bid - Pbid)/(tc-Ptc);                      // intant. bid vel. calc.
        AskVelSum = AskVelSum + Avel;                      // last ask vel added to sum
        BidVelSum = BidVelSum + Bvel;                      // last bid vel added to sum        
     }
     else if(time != LastSec)   {                          //it is not w/in last sec., calculate how many sec. have elapsed empty, and write them as zero vel. in file 
        dif = time - LastSec;                              // number of sec. difference (empty seconds)
        Print("dif = ", dif);
        for(i = 0; i<dif; i++)   { 
           err = FileWrite(handle, 
                           TimeToStr(LastSec+i,TIME_DATE), TimeToStr(LastSec+i,TIME_SECONDS), Ask, 
                           AskVelSum, Bid, BidVelSum  );
          Print("AskVelSum=",AskVelSum,"   BidVelSum=",BidVelSum,"   i=",i,"   dif=",dif,"   lastsec+i=", LastSec+i, "   time=",time );
          AskVelSum = 0.0;
          BidVelSum = 0.0;
        }
        Print("this is what i equals after loop:",i);
     }
     
          
     LastSec = time;                                    //
     Ptc = tc;
     Pask = ask;
     Pbid = bid;     
   }
   return(0);
}


int deinit()   {
   FileClose(handle);
   return(0);
}