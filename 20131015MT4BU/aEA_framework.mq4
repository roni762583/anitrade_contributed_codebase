//+------------------------------------------------------------------+
//|                                                aEA_framework.mq4 |
//|                           Copyright 2012, anitani Software Corp. |
//|                                           http://www.anitani.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, anitani Software Corp."
#property link      "http://www.anitani.com"
//each strategy has unique identification number encoded as last 3 digits of magic number
//each strategy consists of an entry-strategy, and an exit-strategy that are thus bound together
//entry-strategy is a collection of rules and conditions required for entry
//exit-strategy is a collection of rules and conditions required for exit
//magic number is composed of 2 parts: EA no., and Strategy no. corresponding to the associated strategy


extern double bandsDev           = 3.0;     //standard deiations BB seeting, 2.0 is common
extern int    pointExceedingBB   = 1;       //min. points range needs to exceed BB in signal to trigger
extern int    minimumPipTarget   = 60;      //min. pips needed in range to trigger signal

static int    EAno               = 76258;   //EA number
static int    s001, s002;                   //signals
static string sEAno;                        //string type EA number
static bool   test               = true;    //used for testing and debugging


double        orders[50][3]; //[R][C], [R][{ticket no., trail dist., max. profit reached}] to be used in trailStop()


int init()  {
   double dEAno = EAno;
   sEAno = DoubleToStr(dEAno, 0); //store EA number as string 
   ArrayInitialize(orders, 0.0); //initialize array to be used in trailStop()
   return(0);
}



int start()   {
   //refresh rates and singals
   RefreshRates();
   RefreshSignals();
   if(test) int r  = OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, 0, 0, "comment", magic(), 0, Blue);
   if(r>0) test = false;
   //Check for exit of open positions
   checkExit();
   
   //Check for entry conditions
   //checkEntry();
   
   //refresh chart objects and comments
   //refreshChart();
   return(0);
}



void RefreshSignals()   {
   //
   double rangeAvg  = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDev, 20, 5, 0, 0);
   double upperBB   = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDev, 20, 5, 1, 0);
   //double rangeAvg1 = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDev, 20, 5, 0, 1);
   //double upperBB1  = iCustom(NULL, 0, "Aharon_Bands_on_Range", bandsDev, 20, 5, 1, 1);
   if(rangeAvg>=upperBB+pointExceedingBB*Point) s001 = 1; else s001 = 0;
   if(rangeAvg>=minimumPipTarget*Point)         s002 = 1; else s002 = 0;
   //Print("hello from RefreshSignals() ", s001, ", ", s002);//ok
}

int magic()   {   //generates magic number for orders to be sent
   return(76258101);
}

void checkExit()   {
   //loop through open orders
   //for each, compare current conditions to exit strategy:
   //1. identify strategy associated with the open order
   //2. check exit-strategy associated with strategy (strategy consists of entry and exit strategies)
   //3. check exit rules in the exit strategy if conditions to exit are present
   //4. for trailing-stop, exit-strategy should specify distance parameter and/or other parameters when calling trailingStop() funct.
   for(int i=0; i<=OrdersTotal(); i++)   {                    //loop over open orders
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);             //select order 
      int     magic = OrderMagicNumber();                     //get order magic  number
      double dMagic = magic;                                  //cast magic number to double type
      string sMagic = DoubleToStr(dMagic, 0);                 //cast magic number to string 
      int orderType = OrderType();
      if(orderType<2 && StringSubstr(sMagic, 0, 5)==sEAno ) { //if open order (0-buy, 1-sell, other>1), and order from this EA number...
         string sStrategyNo = StringSubstr(sMagic, 5, 3);     //extract strategy sub-string
         if(CheckForExit(GetExitStrategy(sStrategyNo)))   {   //check for exit conditions in corresponding exit strategy
            OrderClose(OrderTicket(), OrderLots(), Price(OrderType()), 2, Color(OrderType()));
      }//close if(OrderType...
   }//close for loop
   return;
}//close funct.



void checkEntry()   {
   int registeredStrategies = checkStrategyRegister();
   for(int i=0; i<=registeredStrategies; i++)  { //loop over entry strategies
      
   }//close for loop
   return;
}



void trailStop()   {//1
   double price;
   for(int i=0; i<OrdersTotal(); i++)   {//2
      
      //any ticket numbers that are in array but not open, should be verified as closed against history,
      //after which be deleted from orders array 
      //in correspondence to each ticket number, will be max. profit attained to check against recession from trail distance
      //upon which will be closed
      
      //scan open orders and any ticket numbers that are not listed in orders array to be added
      double dTicket;                                         // to cast ticket # int to double
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);             //select order 
      dTicket = OrderTicket();                                //cast ticket # int to double
      if(OrderMagicNumber()==EAno)   {  //3                      //if order is from this EA (coded in magic number) ...
                                                              // orders[50][3]; //[R][C], [R][{ticket no., trail dist., max. profit reached}]
         ArraySort(orders, WHOLE_ARRAY, 0, MODE_DESCEND);     //must sort array before it can be searched, put filled rows on bottom of array 
         
         int indx = ArrayBsearch(orders, dTicket, WHOLE_ARRAY, 0, MODE_DESCEND); //return index of ticket, or nearest smallest...check if correct
         if(orders[indx][0]==dTicket)   {                     //ArrayBsearch() succeeded, i.e. there is such an order registered in array 
            //if(OrderType()>=2 &&
         }//close if(orders[....
         else   {                                             //ArrayBsearch() did not succeed, i.e. this order is not registered with orders[][] array 
            //add order to order[][] array
            orders[49][0] = dTicket;
            //orders[49][1] = get trail distance from strategy???
         }//close else 
      }//close if(OrderMagicNumber...
   }//close for loop
}//close function





int checkStrategyRegister()  {   //returns number entry strategies registered
   return(1);
}



void refreshChart()   {   //update chart objects and comments
   Comment("Bid ", Bid);
   return;
}






int deinit()  {
   return(0);
}


