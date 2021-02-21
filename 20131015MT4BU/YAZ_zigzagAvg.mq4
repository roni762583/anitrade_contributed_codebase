//abandoned due to ind. changing backwards
//+------------------------------------------------------------------+
//|                    YAZ_zigzagAvg.mq4
//  after new zigzag peak sell, after zigzag troth buy, use OrderCloseBy() to avg.price 
//|                      Copyright © 2013,     aharon Software Corp. |
//|                                       http://www.google.com      |
//+------------------------------------------------------------------+
//to enter on multiple indicators exit on parabolic sar

#define MAGICMA  20130509
extern bool     fileWriter         = false;//whether to write data to file 
extern double   Lots               = 0.01;
extern bool     useMM              = false;
extern double   MaximumRisk        = 0.02;
extern double   DecreaseFactor     = 0.0;

//trailing stop loss parameters             
extern double   trailPts           = 700.0;
extern double   TrlDcrsRtPipPerBar = 100.0;
extern double   minTrlDistPoints   = 700.0;  
//indicator parameters
extern int      AMAn               = 10;
extern int      AMAnmin            = 2;
extern int      AMAnmax            = 5;
extern int      maPeriod           = 5;
extern int      BBperiod           = 15;
extern int      BBdeviation        = 2;
extern int      BBshft             = 0;  
//extern bool     Contrarian         = false;                //whether to trade entry opposite the signal (correction move after the signal)

static double   OPHWM              = 99999.0;              // order profit high watermark
static double   op;                                        // hold order profit
static double   entrySig;                                  // for entry signal
static double   PrevEntrySig;                              // for signal on prev. bar 

static double   DollarTrailDist;                           // for trail stop distance in dollars

static string   lastOrderTimeString;                       // used for not sending a second order during same minute

static bool     exit = false;

static int      orderCount         = 0;
                
static datetime orderAge;
static datetime pAge;
static datetime  timeOfLastBar;               //required for isNewBar()
       
       int      i;

int handle;  //handle for file
int err;     //error 

void start()   {
   //---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
   if(isNewBar())   {                                // on new bar ...
      for(i=0; i<5; i++)   {
         double zz = iCustom(Symbol(),0,"ZigZag", 0, i);
         if(zz!=NULL) Print("zz=",zz,"  at:",Time[i]);
      }//close for loop
   
      /*
      if(fileWriter)   {  
         err = FileWrite(handle, 
                         Time[1], Open[1], High[1], Low[1], Close[1], PrevEntrySig  );
      }//close if(fileWriter)
      */
   }//close if(isNewBar())...
   
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
}


int CalculateCurrentOrders(string symbol)  {
   int buys=0,sells=0;
   
   for(int i=0;i<OrdersTotal();i++)   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)   {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
      }
   }

   if(buys>0) return(buys);
   else       return(-sells);
}//close function


void CheckForOpen()   {

   int    res;                                             //result of trade
   
   //---- go trading only for first ticks of new bar
   //if(Volume[0]>1) return;
   
   //---- sell conditions
   if(entrySig<0.0 && TimeToStr(Time[0],TIME_MINUTES)!=lastOrderTimeString)    { 
   //Print("sell signal detected");
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
      lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES);//prevent reentering market at same minute as last order
      orderCount =  orderCount +1;
      return;
   }//close if(Open[....
   
                                                           //---- buy conditions
   if(entrySig>0.0 && TimeToStr(Time[0],TIME_MINUTES)!=lastOrderTimeString)   {
   //Print("buy signal detected");
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
      lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES);
      orderCount =  orderCount +1;
      return;
   }//close if(Open[...
}//close CheckForOpen()


void CheckForClose()   {
   exit = false;                                           // start with exit signal off 
   for(i=0;i<OrdersTotal();i++)   {                        // scan open orders for magic and symbol matching
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      op = OrderProfit();                                  // set Order Profit var.
      orderAge = (TimeCurrent()-OrderOpenTime())/60.0;     // update age of order in min. 
      
      if(OPHWM == 99999.0)  {                              // initialize OPHWM, DollarTrailDist
         DollarTrailDist = trailPts*MarketInfo(Symbol(),MODE_TICKVALUE)*OrderLots();
         OPHWM = OrderProfit();                            // initially set OPHWM
         //pullBack = 0.0;                                   //pull back from OPHWM
      }
      
      if(OrderProfit()>OPHWM) OPHWM = OrderProfit();       //update order profit high watermark
      if(OPHWM!=99999.0)   {
         //if(op
      
      }//close if(OPHWM!=99999.0)   {
      
      //update DollarTrailDist
      DollarTrailDist = MathMax(minTrlDistPoints, 
                                (trailPts-TrlDcrsRtPipPerBar*orderAge/Period()))
                                *MarketInfo(Symbol(),MODE_TICKVALUE)*OrderLots();


      if(op <= 0.0-DollarTrailDist)   {
         exit=true; 
         //Print("exit on op <= 0.0-DollarTrailDist");
      }
      if(OPHWM-op>= DollarTrailDist)   {
         exit = true;
         //Print("exit OPHWM[",OPHWM,"]-op[",op,"]>=DollarTrailDist[",DollarTrailDist,", age=",orderAge);
      }
      
      
      //---- check order type 
      if(OrderType()==OP_BUY)  {                           // if long...
         if(exit)  {                                       // if exit signal
            OrderClose(OrderTicket(),OrderLots(),Bid,3,White); //then close position
            OPHWM = 99999.0;                               // reset OPHWM to reset, trl, & pullBackMax above
            lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES); //set last trade time 
            
         }
         break;
      }//close if(OrderType()...)
      
      
      if(OrderType()==OP_SELL)  {                          // if short...
         if(exit)   {                                      // if exit signal
            OrderClose(OrderTicket(),OrderLots(),Ask,3,White); // close position
            OPHWM = 99999.0;                               // reset OPHWM to reset, trl, & pullBackMax abov
            lastOrderTimeString = TimeToStr(Time[0],TIME_MINUTES); //set last trade time 
      
         }
         break;
      }//close if(OrderType()...
   }//close for(...
}//close function


double LotsOptimized()   {
   double lot = Lots; //0.01
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break

   if(useMM) lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

   if(DecreaseFactor>0)   {
      //---- calcuulate number of losses orders without a break
      for(int i=orders-1;i>=0;i--)   {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;

         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
      }//close for(int i=...
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   }//close if(DecreaseFactor>0)
   if(lot<0.01) lot=0.01;
   return(lot);
}//close function



bool isNewBar()   { //returns whether this is a new Bar. Requires static datetime var. timeOfLastBar
   datetime timeThisBar = Time[0];
   if(timeThisBar != timeOfLastBar)   {
       timeOfLastBar = timeThisBar;
       return(true);
   }
   else return(false);
}//close function isNewBar()



int init()  {
  
   
   if(fileWriter)    {
      string filename = StringConcatenate("yaz_", Symbol(), ".", TimeToStr(TimeCurrent(),TIME_DATE), ".", TimeCurrent(), ".csv");
      handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
 
      err = FileWrite(handle, "Time", "Open", "High", "Low", "Close", "Signal" );
      Print("err=",err);
      if(handle<1)   {
         Print("File ", filename, " error, the last error is ", GetLastError());
         return(false);
      }//close if(handle
      else Print("File ", filename, "  handle = ", handle);
   }
   return(0);
}



int deinit()   {
   if(fileWriter) FileClose(handle);
   return(0);
}





