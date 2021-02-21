//+------------------------------------------------------------------+
//|                                         kalman filter simple.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


static datetime time = 0,  //stores current bar open time 
                lastTime =0 ;//stores last bar open time 

static double   dup     = 0.0,
                ddn     = 0.0, //to hold kalman filter value
                dir     = 9.0, //this is direction up is 1.0, down is -1.0, 9.0 is neither - initialized
                lastDir = 9.0, //to store last direction
                cd      = 9.0; //to store current position directio
       
       bool     newBar = false; //flag when new bar is started
                
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   
   time = Time[0];
   
   if(time!=lastTime) { //if current time is new from previous
      lastTime = time;  //set previous time variable to new time 
      newBar = true;  //set newBar flat to true
      // Print("time this bar = ", TimeToStr(lastTime, TIME_DATE|TIME_SECONDS)  ); //works good to here
   }
      

   dup = iCustom(NULL, 0, "kalman filter",/* 6,1,1,5000,*/ 0, 1);
   ddn = iCustom(NULL, 0, "kalman filter",/* 6,1,1,5000,*/ 1, 1);


   //determine if it is up or down
   if(dup!=0 && ddn>9999) dir = 1.0; //1.0 is up, -1.0 is down
   if(dup>9999 && ddn!=0) dir = -1.0; //same as above

   //see if it changed from previous
   if(dir != lastDir)   {//then if it changed from previous, 
      lastDir = dir; //reset lastDir to current direction
      Print("dir = ", dir, "   time = ", Time[1]);
      //before closing positions, maybe it oscilated direction so verify position direction as well
      if(!isFlat()) cd = currentDir(); //if not flat which direction is position?
      if(cd==dir) {Print("something is wrong! cd=dir");}//something is wrong!
      if(cd==0.0) Print("Something is wrong!! check code");
      if(cd!=dir) {//indeed is new direction, rebalance position in accordence with new direction
         closeAll();    //close open orders,
         //and if flat, open new order in correct direction
         if(dir==1.0 && isFlat() /*&& newBar*/) OrderSend(Symbol(), OP_BUY,  1, Ask, 3, 0 /*Ask-25*Point*/, 0 /*Ask+25*Point*/, "test", 6718, 0, Green);
         if(dir==0.0 && isFlat() /*&& newBar*/) OrderSend(Symbol(), OP_SELL, 1, Bid, 3, 0 /*Bid+25*Point*/, 0 /*Bid-25*Point*/, "test", 6718, 0, Red);
      }
      
   }
   
   return(0);
}//close start()


double currentDir()   { //returns whether current position is long or short for this EA magic number
   int totalOrders = 0;
   double  ot = 0.0; //order type: 1.0 is long, -1.0 is short 
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
            totalOrders++;
            if(OrderType()==0) ot = 1.0; //long 
            if(OrderType()==1) ot = -1.0;//short 
         }//close if(OrderSelect...
   }//close for loop
   if(totalOrders>1) {
      Print("alert! more than one order detected (from currentDir())");
      return(0.0);
   }
   Print("hello from currebtDir(): cd=", cd, "  totalOrders = ", totalOrders);
   return(ot);
}//close isFlat()


bool isFlat()  { //will return true if no open orders from this EA magic - ignores other orders in system, ignores pending and historical orders 
   int totalOrders = 0;
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                           //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
            totalOrders++;
         }//close if(OrderSelect...
   }//close for loop
   Print("isFlat() totalOrders = ", totalOrders);
   if(totalOrders==0) return(true);
   return(false);
}//close isFlat()
         


void closeAll() {
   double price = 0.0;                             //to hold order close price bid or ask 
   for(int i=0; i<OrdersTotal(); i++)   {          //loop over position
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);  //select order 
      if(OrderType()<2 &&                            //if open order (0-buy, 1-sell, other>1), and
         OrderMagicNumber() ==  6718)   {          //order from this EA magic number...
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


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }