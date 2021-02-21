//+------------------------------------------------------------------+
//|                                            AZ_CheckModelling.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                               CheckModelling.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net/     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
 
//---- input parameters
extern int       DayS=21;
extern int       MonthS=4;
extern int       YearS=2006;
extern int       HourS=10;
extern int       MinuteS=00;
extern int       CounterS=20;
int counter;
int start()
  {
//----
   if (counter>CounterS) return;
   if (Year()<2006) return;
   if (Month()<MonthS) return;
   if (Day()<DayS) return;
   if (Hour()<HourS) return;
   if (Minute()<MinuteS) return;
   Print("My time frame   "," Open=",Open[0],"  High=",High[0],"   Low=",Low[0],
      "  Close=",Close[0],"  Volume=",Volume[0],"  Bid=",Bid);
   Print("30 minute frame "," Open=",iOpen(NULL,PERIOD_M30,0),"  High=",iHigh(NULL,PERIOD_M30,0),
      "   Low=",iLow(NULL,PERIOD_M30,0),"  Close=",iClose(NULL,PERIOD_M30,0),
      "  Volume=",iVolume(NULL,PERIOD_M30,0),"  Bid=",Bid);
   Print("1 hour frame    "," Open=",iOpen(NULL,PERIOD_H1,0),"  High=",iHigh(NULL,PERIOD_H1,0),
      "   Low=",iLow(NULL,PERIOD_H1,0),"  Close=",iClose(NULL,PERIOD_H1,0),
      "  Volume=",iVolume(NULL,PERIOD_H1,0),"  Bid=",Bid);
   Print("4 hour frame    "," Open=",iOpen(NULL,PERIOD_H4,0),"  High=",iHigh(NULL,PERIOD_H4,0),
      "   Low=",iLow(NULL,PERIOD_H4,0),"  Close=",iClose(NULL,PERIOD_H4,0),
      "  Volume=",iVolume(NULL,PERIOD_H4,0),"  Bid=",Bid);
 
   counter++;  
//----
   return(0);
  }
//+------------------------------------------------------------------+