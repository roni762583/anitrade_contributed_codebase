//+------------------------------------------------------------------+
//|                                             aEA_Price_Logger.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


static    int handle;

int init()   {
   string pair = Symbol();                                                     // symbol of instrument 
   string startDate = TimeToStr(TimeCurrent(), TIME_DATE);                     // date file openned
   string startTime = TimeToStr(TimeCurrent(), TIME_SECONDS);                  // time file openned
   string broker    = TerminalCompany() ;                                      // in case running on several brokers
   string fileName  = pair + "_" + broker + "_" + startDate + "_" + startTime; // constructed file name
   // cleanout spaces and colons
   int position = -9;                                                          // variable to hold position in string search
   while(position != -1)   {                                                   // check for completion of operation
      position  = StringFind(fileName, ":", 0);                                // look for colon
      if(position == -1) position  = StringFind(fileName, ",", 0);             // look for comma space
      if(position == -1) position  = StringFind(fileName, " ", 0);             // look for spaces
      if(position == -1) position  = StringFind(fileName, ".", 0);             // look for periods 
      // change spaces, commas, periods, and colons tp underscores to condition file name
      fileName = StringSetChar(fileName, position, '_');
   }
   fileName = fileName + ".csv"; 
   Print("fileName=",fileName);
   handle = FileOpen(fileName,FILE_CSV|FILE_WRITE,',');
   if(handle<1)   {
      Print("FileOpen() failed with error ", GetLastError());
      return(false);
   }
   FileWrite(handle, "date.time", "mSec", "Bid", "Ask");
   FileFlush(handle);
   return(0);
}



int start()  {
//later add continual loop to check for connection to server,
//and make indication of gap in data, otherwise won't know when disconnected from server
   datetime tc      = TimeCurrent();                                                     //get server time 
   string timeStamp = TimeToStr(tc|TIME_SECONDS);                     //not working right!
                                      //convert to string
   int    mSec      =  GetTickCount();                                              //get mSec time stamp (local machine)
   FileWrite(handle, timeStamp, mSec, Bid, Ask);                            //write data
   FileFlush(handle);
   /*
   Print("stuff=",StringSubstr(timeStamp, StringLen(timeStamp)-3));
   if(StringSubstr(timeStamp, StringLen(timeStamp)-1) == "00" != )   {
      FileFlush(handle); //once a minute, on the minute, flush to disk 
      Print("flushed");
   }*/
   return(0);
}



int deinit()   {
   FileClose(handle) ;
   return(0);
}