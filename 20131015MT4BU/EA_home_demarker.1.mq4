//+------------------------------------------------------------------+
//|                                         EA_home_demarker.1.mq4 |
//|                        Copyright 2012, anitani Software Corp. |
//|                                        http://www.anitani.com  |
//+------------------------------------------------------------------+
//USE ON 4H TF ONLY


#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"


extern bool      useSL             = false,
                 useTP             = false;
                 
extern int       TP                = 250,
                 SL                = 250,
                 magicNo           = 6718;


static double    firstLowValue     = 9.0,   //to hold value of first/right low of uptrend/demand line 
                 secondLowValue    = 9.0,   //to hold value of second/left low of uptrend/demand line 
                 highestValue      = 0.0,   //to store value of highest high over demand trendline
                 diffHandIntersect = 0.0,   //difference btwn highest-High and trendline 
                 openBelowTLvalue  = 0.0,   //value of Open of break-trough bar 
                 shortTarget       = 0.0;   //holds target price (TP) on short following break-through

static bool      go                = true,  //control execution during development and debugging
                 firstLowFound     = false, //flag indicating operation complete
                 secondLowFound    = false, //flag indicating operation complete
                 trendLinesSet     = false; //flag indicating operation complete
                 
static datetime  firstLowTime,             //stores time of right low in uptrend line
                 secondLowTime,            //stores time of left low in uptrend line
                 lastBarOpenTime,          //is used with IsNewBar() funct.
                 highestTime,              //stores time of highest high over demand trendline
                 openBelowTLtime;          //stores time when opened below trendline (break-through time)
                 
                 
       int       H4bars            = 0; //to hold number on bars available on the 4H chart 
       
       double    L                 = 0.0,  //to hold Low price 
                 Lp1               = 0.0,  //Low plus 1 in index (ie one to left)
                 Lp2               = 0.0,
                 Lm1               = 0.0,
                 Lm2               = 0.0;


int init()  { //init funct
   //Print("hi from start");
   ObjectsDeleteAll();
   return(0); 
} 


int start()  {
if(go){//control for debugging only
   int i = 0;
   
   if(!trendLinesSet)   { //this block will run only when trendlines have not yet been calculated and set 
      
      //UPTREND LINE CONSTRUCTTED BY TWO LOWS WHERE THE LEFT ONE IS LOWER
      //EACH LOW IS ONLY CONSIDERED IF IT IS CUSHIONED ON BOTH SIDES BY HIGHER LOWS
      
      //SEEK FIRST LOW 
      H4bars = iBars( NULL, PERIOD_H4) ; //number of bars on 4H chart 
      //Print("number of bars on 4H chart available: ", H4bars);

      for(i=2; i<H4bars; i++) {
         //catch bad bar encountered in history in past 
         // Print("string extraction of minutes looks like:", StringSubstr( TimeToStr(iTime(NULL,PERIOD_H4,i), TIME_MINUTES ), 3, 2)  );//     
          
         if(   StringSubstr( TimeToStr(iTime(NULL,PERIOD_H4,i), TIME_MINUTES ), 3, 2) !=
               "00"   ) {
                  Print( "found bad bar ...");
                  continue;
               } //close curly bracket on if statement
         
         
         L   = iLow(NULL, PERIOD_H4, i);
         Lp1 = iLow(NULL, PERIOD_H4, i+1);
         Lp2 = iLow(NULL, PERIOD_H4, i+2);
         Lm1 = iLow(NULL, PERIOD_H4, i-1);
         Lm2 = iLow(NULL, PERIOD_H4, i-2);
         
         //detect first low (right-most) for uptrend/demand line
         if(L<Lm1 && L<Lm2 && L<Lp1 && L<Lp2  && !firstLowFound) { //don't detect if already detected first low 
            firstLowValue = L;                                     //store value for trendline
            firstLowTime  = iTime(NULL, PERIOD_H4, i);             //store time of occurance for trendline
            firstLowFound = true;                                  //set flag true
            //Print("first low found: ", firstLowValue, ", occured at: ", TimeToStr(firstLowTime, TIME_DATE|TIME_MINUTES) );
            ObjectCreate("vln1", OBJ_VLINE, 0, firstLowTime, firstLowValue);         //draw vertical line on low detected
            ObjectSet("vln1", OBJPROP_COLOR, Green);                                 //make it green
            continue; //in order that a second low may be detected rather than a duplicate 
         }//close if( for first low 
         
         //detect second low (left-low) for uptrend/demand line
         if(L<Lm1 && L<Lm2 && L<Lp1 && L<Lp2  && L<=firstLowValue && firstLowFound  && !secondLowFound) {
                                                                                     //left low has to be less-than or equal to right low 
                                                                                     //first (right most) low  must have been found
                                                                                     //and left Low not yet found
            secondLowValue = L;                                                      //store value for trendline
            secondLowTime  = iTime(NULL, PERIOD_H4, i);                              //store time of occurance for trendline
            secondLowFound = true;                                                   //set flag true
            //Print("second low found: ", secondLowValue, ", occured at: ", TimeToStr(secondLowTime, TIME_DATE|TIME_MINUTES) );
            ObjectCreate("vln2", OBJ_VLINE, 0, secondLowTime, secondLowValue);       //draw vertical line on low detected
            ObjectSet("vln2", OBJPROP_COLOR, Green);                                 //make it green
            break; //get out of for loop once second low is found
         }//close if( for second low 
                 
      }//close for loop
      
      //draw uptrend/demand line
      if(firstLowFound && secondLowFound) {
         ObjectCreate("uptrendLn", OBJ_TREND, 0, secondLowTime, secondLowValue, firstLowTime, firstLowValue);//assumes MT4 reads left to right?
         ObjectSet("uptrendLn", OBJPROP_COLOR, Blue);
      }//close if for drawing uptrend line
      
      trendLinesSet = true; //set flag true
      
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
            
   }//closes if(!trendLinesSet)   
   
   
   //this block of code will detect a bar opening below uptrend (later to add downtrend calculations as well)
   //this will need to execute on trendline/s detected previously
   
   //on newBar, is Open below uptrend line projected?
   if(isNewBar())   {                                                           //only claculate on new bar openning
      double iO = iOpen(NULL, PERIOD_H4, 0);                                          //store Open price of new bar 
      double uT = ObjectGetValueByShift("uptrendLn", 0);                              //store trendline value
      if(ObjectFind("lable tLv") != -1) ObjectDelete("lable tLv");                    //if an old one exists, delete it
      if(ObjectFind("lable tLv")==-1)   {                                             // object not yet created/exist
         ObjectCreate("lable tLv", OBJ_LABEL, 0, 0,0);                                //create label to indicate trendline value for debugging purposes
         ObjectSet("lable tLv", OBJPROP_XDISTANCE, 100);                              //set x-dist in pixels
         ObjectSet("lable tLv", OBJPROP_YDISTANCE, 100);                              //set y-dist in pixels
         string s = DoubleToStr(uT, 5);                                               //set string s to value of trendline to 5 decimal points 
         ObjectSetText("lable tLv", s, 10, "Times New Roman", Blue);                  //set text of lable
      }//close if(ObjectFind(...
      
      if( iO < uT ) { //if new Open is below uptren line
         openBelowTLtime  = iTime(NULL, PERIOD_H4, 0);                                //stores time of break-trough
         openBelowTLvalue = iOpen(NULL, PERIOD_H4, 0);                                //stores Open of break-trough bar 
         
         ObjectCreate("openBelowTLdetected", OBJ_LABEL, 0, 0,0);                      //create label to indicate trendline broken
         ObjectSet("openBelowTLdetected", OBJPROP_XDISTANCE, 150);                              //set x-dist in pixels
         ObjectSet("openBelowTLdetected", OBJPROP_YDISTANCE, 150);                              //set y-dist in pixels
         ObjectSetText("openBelowTLdetected", 
                       "Detected Open below demand trendline at " + openBelowTLvalue + "  at " + TimeToStr(openBelowTLtime, TIME_MINUTES), 
                       10, "Times New Roman", Red);                                           //set text of lable
         
         ObjectCreate("vln3", OBJ_VLINE, 0, openBelowTLtime, 0);                              //draw vertical line on low detected
         ObjectSet("vln3", OBJPROP_COLOR, Red);                                               //make it Red
         
         //send SELL order with target = Open - diffHandIntersect
         shortTarget = NormalizeDouble((openBelowTLvalue - diffHandIntersect), Digits);
         
         //draw horiz. line at target 
         ObjectCreate("shortTarget", OBJ_HLINE, 0, 0, shortTarget);                           //draw vertical line on low detected
         ObjectSet("shortTarget", OBJPROP_COLOR, Red);                                        //make it Red
         
         if(isFlat()) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", magicNo, 0, Red);
         
         //go = false; return(0); //control point for debugging
         
      }//close if( iOpen(...
   }//close if(isNewBar())
   
   
   return(0);
}//close if(go)... control for debugging only   
} //close start()


   //

      //if both TF's have same trend direction, and position is flat, enter order in trend direction
  //    if(dir_TF1 == dir_TF2 && isFlat())   {
  //       //Print("dir_TF1 = ", dir_TF1, ", and dir_TF2 = ", dir_TF2, "  right b4 sending order");
 //        if(dir_TF1 > 0.0) OrderSend(Symbol(), OP_BUY,  1, Ask, 3, buyStopLoss(), buyTakeProfit(), "test", magicNo, 0, Green);
 //        if(dir_TF1 < 0.0) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, sellStopLoss(), sellTakeProfit(), "test", magicNo, 0, Red);
  //    }//close if(dir_TF1 == dir_TF2 &&....
      
      //Print("AoA_TF1=", AoA_TF1, "    A_TF1=", A_TF1);
      
      

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


double longOrShort()   {
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