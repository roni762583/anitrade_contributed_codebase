//+------------------------------------------------------------------+
//|                                         Aharon_Clock_Comment.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   Comment("waiting for first tick");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   datetime l, s, del;
   int di;
   l = TimeLocal();
   s = TimeCurrent();
   del = s - l;
   di = (s - l)/3600;
   
   Alert("Date Time of last bar is:" + "\n" +
         TimeToStr(Time[0], TIME_DATE|TIME_MINUTES) + "\n" +
         TimeToStr(Time[0], TIME_DATE|TIME_SECONDS) );
//----
   Comment("Local machine time is " + TimeToStr( l, TIME_DATE|TIME_SECONDS) + "\n" +
           "Last server time is "   + TimeToStr( s, TIME_DATE|TIME_SECONDS) + "\n" +
           "Difference (server - local) is " + TimeToStr( del, TIME_DATE|TIME_SECONDS) + "\n" +
           "di = " + di+ "\n" +
           "TIME_MINUTES format  = " + TimeToStr( s, TIME_MINUTES)  ); 
//----
   return(0);
  }
//+------------------------------------------------------------------+