//+------------------------------------------------------------------+
//|                                                A_file_writer.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

int handle;  //handle for file
int err;     //error 


int init()   {
   string filename = StringConcatenate( Symbol(), TimeToStr(TimeCurrent(),TIME_DATE),".",GetTickCount(), ".csv");//|TIME_SECONDS
   
   handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
  
   if(handle<1)   {
     Print("File ", filename, " error, the last error is ", GetLastError());
     return(false);
   }
   else Print("handle = ", handle);
   
    
   return(0);
}


int deinit()   {
   FileClose(handle);
   return(0);
}


int start()   {   
   if(handle>0)   {
     err = FileWrite(handle, Bid, Ask, TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), GetTickCount());
     if(err<0) Print("File write error ", GetLastError());
   }
   return(0);
}

