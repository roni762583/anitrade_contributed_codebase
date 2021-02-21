//+------------------------------------------------------------------+
//|                                         EA_home_demarker.2.mq4 |
//|                        Copyright 2012, anitani Software Corp. |
//|                                        http://www.anitani.com  |
//+------------------------------------------------------------------+
//USE ON 4H TF ONLY
////////////////////////////// NEED TO GET IT TO RESPOND AFTER INITIAL TL SETUP

#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"

extern double    lots                   = 0.1,                                           //size of order trade
                 minProfit              = 0.0006;                                        //criteria for entry, later to be updated

extern bool      useSL                  = false,
                 useTP                  = false;
                 
extern int       TP                     = 250,
                 SL                     = 250,
                 magicNo                = 6718;

static int       Ticket                 = 0;                                             //to hold order ticket number

static double    firstLowValue          = 9.0,                                           //to hold value of first/right low of uptrend/demand line 
                 secondLowValue         = 9.0,                                           //to hold value of second/left low of uptrend/demand line 
                 highestValue           = 0.0,                                           //to store value of highest high over demand trendline
                 diffHandIntersect      = 0.0,                                           //difference btwn highest-High and trendline 
                 openBelowTLvalue       = 0.0,                                           //value of Open of break-trough bar 
                 shortTarget            = 0.0;                                           //holds target price (TP) on short following break-through

static bool      go                     = true,                                          //control execution during development and debugging
                 firstLowFound          = false,                                         //flag indicating operation complete
                 secondLowFound         = false,                                         //flag indicating operation complete
                 trendLinesSet          = false,                                         //flag indicating operation complete
                 newFirstLow_FindSecond = false,                                         // flag indicating need to keep up search for second Low
                 newSecondLow_recalcTL  = true,                                          //flag indicating need to recalculate trend-line
                 newTLrecalcTarget      = true;                            // flag to indicate new TL has been created...reCalculate Target price 
                 
static datetime  firstLowTime = 0,                                                       //stores time of right low in uptrend line
                 secondLowTime,                                                          //stores time of left low in uptrend line
                 lastBarOpenTime,                                                        //is used with IsNewBar() funct.
                 highestTime,                                                            //stores time of highest high over demand trendline
                 openBelowTLtime,                                                        //stores time when opened below trendline (break-through time)
                 prevFirstLowTime = 1;                                                   //stores prev.datetime value of fist Low to detect change
                 
                 
       int       H4bars            = 0;                                                  //to hold number on bars available on the 4H chart 
       
       double    L                 = 0.0,                                                //to hold Low price 
                 Lp1               = 0.0,                                                //Low plus 1 in index (ie one to left)
                 Lp2               = 0.0,
                 Lm1               = 0.0,
                 Lm2               = 0.0;


int init()  { //init funct
   //Print("hi from start");
   ObjectsDeleteAll();
   return(0); 
} 


int start()  {
//if(go){//control for debugging only
   int i = 0;
   double uT, iO;
///////////// Things that happen on new bar /////////////////////////   
   if(isNewBar())   {   //if new bar formed
      //find first (right most) key-reversal low, AND IDENTIFY IT BY OPEN TIME, if new Low-then udate trend line
      //UPTREND LINE CONSTRUCTTED BY TWO LOWS WHERE THE LEFT ONE IS LOWER
      //EACH LOW IS ONLY CONSIDERED IF IT IS CUSHIONED ON BOTH SIDES BY HIGHER LOWS
      
      //SEEK FIRST LOW 
      H4bars = iBars( NULL, PERIOD_H4) ; //number of bars on 4H chart 
      //Print("number of bars on 4H chart available: ", H4bars);
      for(i=2; i<H4bars; i++) { //loop over chart till found...
         //catch bad bar encountered in history in past 
         // Print("string extraction of minutes looks like:", StringSubstr( TimeToStr(iTime(NULL,PERIOD_H4,i), TIME_MINUTES ), 3, 2)  );//     
         if(StringSubstr( TimeToStr(iTime(NULL,PERIOD_H4,i), TIME_MINUTES ), 3, 2) !=
               "00"   ) {
                //  Print( "found bad bar ...");
               //   continue;  //modified to not disinclude 'bad bars'
         } //close if(StringSubstr(...
         
         L   = iLow(NULL, PERIOD_H4, i);
         Lp1 = iLow(NULL, PERIOD_H4, i+1);
         Lp2 = iLow(NULL, PERIOD_H4, i+2);
         Lm1 = iLow(NULL, PERIOD_H4, i-1);
         Lm2 = iLow(NULL, PERIOD_H4, i-2);
         
         //detect FIRST low (right-most) for uptrend/demand line
         if(L<Lm1 && L<Lm2 && L<Lp1 && L<Lp2 && firstLowTime!=prevFirstLowTime){         //if new low detected 
            firstLowValue = L;                                                           //store value for trendline
            firstLowTime  = iTime(NULL, PERIOD_H4, i);                                   //store time of occurance for trendline
            newFirstLow_FindSecond = true;                                               // flag indicating need to keep up search for second Low
            prevFirstLowTime = firstLowTime;                                             // set prevFirstLowTime to new Low time 

            ObjectCreate("vln1", OBJ_VLINE, 0, firstLowTime, firstLowValue);             //draw vertical line on low detected
            ObjectSet("vln1", OBJPROP_COLOR, Green);                                     //make it green
            continue;                                        //in order that a second low may be detected rather than a duplicate 
         }//close if( for first low 
         
         //if new Low developed that is different from previous low, then RECALCULATE SECOND LOW (LEFT LOW)
         if(newFirstLow_FindSecond)   {                                                  //if need to search for second (left) Low...
            if(L<Lm1 && L<Lm2 && L<Lp1 && L<Lp2  && L<=firstLowValue) {                  //left low has to be less-than or equal to right low 
               newFirstLow_FindSecond = false;                                           //reset flag to find SECOND LOW
               secondLowValue = L;                                                       //store value for trendline
               secondLowTime  = iTime(NULL, PERIOD_H4, i);                               //store time of occurance for trendline
               newSecondLow_recalcTL  = true;                                            //flag indicating need to recalculate trend-line

               ObjectCreate("vln2", OBJ_VLINE, 0, secondLowTime, secondLowValue);        //draw vertical line on low detected
               ObjectSet("vln2", OBJPROP_COLOR, Green);                                  //make it green
            }//close if(L<Lm1 && L<Lm2 && L<Lp1 && L<Lp2  && L<=firstLowValue)...
         }//close if(newFirstLow_FindSecond)...
      }//close for loop...
      
         
      // if NEW SECOND LOW (newSecondLow_recalcTL), recalculate trendline 
      if(newSecondLow_recalcTL)   {                                                      //if new Trend-line is to be calculated
         //create TL obj 
         ObjectCreate("uptrendLn", OBJ_TREND, 0, secondLowTime, secondLowValue, firstLowTime, firstLowValue);//assumes MT4 reads left to right?
         ObjectSet("uptrendLn", OBJPROP_COLOR, Blue);
         newSecondLow_recalcTL = false;                                                  //reset flag (TL is calculated/updated)
         newTLrecalcTarget     = true;                                      //flag to indicate new TL has been created...reCalculate Target price 
      }//close if(newSecondLow_....
         
      //recalculate target TP price (need breakthrough Open)
      if(newTLrecalcTarget)   {                                                          // if new trendline created... recalculate entry
                                                                           //detect highest High above demand line and mark it with vertical line
         int shift1 = iBarShift(NULL,PERIOD_H4, firstLowTime);                           //find relative shift of first low 
         int shift2 = iBarShift(NULL,PERIOD_H4, secondLowTime);                          //find relative shift of second low 
         int shiftHighest = iHighest(NULL, PERIOD_H4, MODE_HIGH, shift2-shift1, shift1); //find chart shift of highest high over trendline
         highestValue = iHigh(NULL, PERIOD_H4, shiftHighest);                            //store value of highest high over trendline
         highestTime  = iTime(NULL, PERIOD_H4, shiftHighest);                            //store time of highest high over trendline
         ObjectCreate("vLnHighest", OBJ_VLINE, 0, highestTime, 0.0);                     //draw vertical line on highest high detected
         ObjectSet("vLnHighest", OBJPROP_COLOR, Turquoise);                              //make it green
         
         //draw horiz line at price level vLnHighest intersects trendline
         double intersectPriceLevel = ObjectGetValueByShift("uptrendLn", shiftHighest);
         ObjectCreate("hLnIntersect", OBJ_HLINE, 0, 0, intersectPriceLevel);
         ObjectSet("hLnIntersect", OBJPROP_COLOR, LightBlue);
         
         //calculate difference btwn highest High above trendline, and horiz- "hLnIntersect" intersect w/ trendline
         diffHandIntersect = highestValue - intersectPriceLevel;                         //This number becomes our price projection.
         Comment("diff = " + diffHandIntersect);
         
         //create lable
         if(ObjectFind("lable tLv") != -1) ObjectDelete("lable tLv");                    //if an old one exists, delete it
         if(ObjectFind("lable tLv")==-1)   {                                             // object not yet created/exist
            ObjectCreate("lable tLv", OBJ_LABEL, 0, 0,0);                                //create label to indicate trendline value for debugging purposes
            ObjectSet("lable tLv", OBJPROP_XDISTANCE, 100);                              //set x-dist in pixels
            ObjectSet("lable tLv", OBJPROP_YDISTANCE, 100);                              //set y-dist in pixels
            string s = "value of TL at zero bar" + DoubleToStr(uT, 5);                   //set string s to value of trendline to 5 decimal points 
            ObjectSetText("lable tLv", s, 10, "Times New Roman", Blue);                  //set text of lable
         }//close if(ObjectFind(...
         
         iO = iOpen(NULL, PERIOD_H4, 0);                                          //store Open price of new bar 
         uT = ObjectGetValueByShift("uptrendLn", 0);                              //store trendline value
           
         if( iO < uT ) { //detect Open is below uptrend line
            openBelowTLtime  = iTime(NULL, PERIOD_H4, 0);                                //stores time of break-trough
            openBelowTLvalue = iOpen(NULL, PERIOD_H4, 0);                                //stores Open of break-trough bar 
         
            //create lable indicating info on breakthrough Open
            ObjectCreate("openBelowTLdetected", OBJ_LABEL, 0, 0,0);                      //create label to indicate trendline broken
            ObjectSet("openBelowTLdetected", OBJPROP_XDISTANCE, 150);                    //set x-dist in pixels
            ObjectSet("openBelowTLdetected", OBJPROP_YDISTANCE, 150);                    //set y-dist in pixels
            ObjectSetText("openBelowTLdetected", 
                          "Open below demand trendline: " + openBelowTLvalue + "  at " + 
                          TimeToStr(openBelowTLtime, TIME_DATE|TIME_MINUTES), 
                          10, "Times New Roman", Red);                                   //set text of lable
            //create vertical line on breakthrough Open
            ObjectCreate("vln3", OBJ_VLINE, 0, openBelowTLtime, 0);                      //draw vertical line on low detected
            ObjectSet("vln3", OBJPROP_COLOR, Red);                                       //make it Red
            
            //calculate TP target target = Open - diffHandIntersect
            shortTarget = NormalizeDouble((openBelowTLvalue - diffHandIntersect), Digits);
            
            //draw horiz. line at target 
            ObjectCreate("shortTarget", OBJ_HLINE, 0, 0, shortTarget);                   //draw vertical line on low detected
            ObjectSet("shortTarget", OBJPROP_COLOR, Red);                                //make it Red
            
            newTLrecalcTarget = false;                                                   //set flag to indicate target TP is calculated
            //at this point, the price TP target is known, because there was a breakthough Open on which it was calculated
            //if flat, send entry order 
            if(isFlat() && Bid-shortTarget>minProfit)   {                                //if flat and target TP is > minimum criteria
               Ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", magicNo, 0, Red);
               if(Ticket==-1) Print("OrderSend failed with error code: ", GetLastError()); //may need to add loop to retry non-critical errors
               if(Ticket>0)  {  //if order went through calculate SL target
                  //shortSLtarget =
               }//close if(Ticket>0)... 
            }//close if(IsFlat()...
         }//close if( iO < uT )... 
      }//close if(newTLrecalcTarget)... 
   }//close if(isNewBar())...
   
      
   ///////////// Things that hapen each tick or loop ///////////////////
   // open order management
   // monitor TP, SL of open orders - do not send orders with SL to avoid broker gunning price
   // adjust SL, TP as conditions change
   // if open short, and latest TP price target is different from OrderTakeProfit(): 
   // modify order: if still in money, to 'new' TP target, 
   // else, if latest TP target is out of money exit to cut losses
   /* TO BE ADDED LATER
   if(longOrShort()==-1.0) {
      if(OrderSelect(Ticket, SELECT_BY_TICKET))   {
         //conditions to kill position: 
         //a)reached SL 
         if(Ask >= shortSLtarget) closeAll();                                             //a) is SL reached? close orders (this is one order EA version)
         //b) reached TP 
         
         //c) new shortTarget is not minimally profitable
         if(OrderOpenPrice() er shortTarget
      }
      else Print("OrderSelect() failed with error code: ", GetLastError());              //may need to add loop to retry non-critical errors 
   */
   return(0);
   //go = false; return(0); //control point for debugging
   //}//close if(go)... control for debugging only   
} //close start()



//function to detect new bar formed
//datetime lastBarOpenTime; //this is moved to top with other variables
bool isNewBar()   {
   datetime thisBarOpenTime = Time[0];
   if(thisBarOpenTime != lastBarOpenTime) {
      lastBarOpenTime = thisBarOpenTime;
      return (true);
   }//close if()...
   else
   return (false);
}//close isNewBar()...



double buyStopLoss()   {
   if(useSL)  {
      return(Ask-SL*Point);
   }
   return(0);
}


double buyTakeProfit()   {
   if(useTP)  {
      return(Ask+TP*Point);
   }
   return(0);
}


double sellStopLoss()   {
   if(useSL)  {
      return(Bid+SL*Point);
   }
   return(0);
}


double sellTakeProfit()   {
   if(useTP)  {
      return(Bid-TP*Point);
   }
   return(shortTarget);
}



void closeAll() { //closes all open positions from this magic number
   double price = 0.0;                             //to hold order close price bid or ask 
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                            //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            if(OrderType()==0)  price = Bid;
            if(OrderType()==1)  price = Ask;
            while(!OrderClose(OrderTicket(), OrderLots(), price, 3, Blue)) { //loop till OrderClose() succeeds
               Print("order close failed with error code ", GetLastError(), "  ...retrying"); //print error code
               Alert("order close failed...retrying"); //send alert 
            } //closes while loop 
            // at this point OrderClose() will have succeeded
      }// close if(OrderType...
   }//close for loop
}//close closeAll()   


bool isFlat()  { //will return true if no open orders from this EA magic - ignores other orders in system, ignores pending and historical orders 
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            totalOrders++;
         }//close if(OrderSelect...
   }//close for loop
   //Print(" from isFlat(): totalOrders = ", totalOrders);
   if(totalOrders==0) return(true);
   return(false);
}//close isFlat()


double longOrShort()   {  //good only for one active position
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  magicNo)   {          //order from this EA magic number...
            if(OrderType()==0) return(1.0);
            if(OrderType()==1) return(-1.0);
      }//close if(OrderType...      
   }//close for loop
}//close longOrShort()



//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }