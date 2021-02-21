//+------------------------------------------------------------------+
//|                                                 Aharon_Gidi1x.mq4 |
//|                                                           Aharon |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Aharon Gidon"
#property link      "http://www.anitani.net"

//---- input parameters
                                                           // Numeric values for M15
extern double TakeProfit = 20;                             // for an opened order
extern double StopLoss   = 20;                             // SL for an opened order
extern double Lots       = 0.10;                           // Strictly set amount of lots   ...do not change this for now, 'tilllots calculation is verified to work

extern int    Iterations = 8;                              // number of bars back (i.e. on TF Min. X Iteration = lookback in Min.)

extern string SR_Levels_To_Time   = "14:00";               // recommended 7:00am – 9:00am NY Time (1200-1400 UK time), for GBP/USD pair
extern string Stop_Trading_Time   = "15:01";               // time to stop sending orders for opening new trades
extern string ResetTime = "00:00";                         // time to reset TradeExecuted flag


bool Work = true;                                          // EA will work.
bool TradeExecuted = false;
bool firstrun = true;

int MinBars = 15;                                          // this is minimum number of bars needed in a chart to operate for MA's, etc. Arb. # for now

double Sup = 9999999.0;                                    // this is for 'support' level for breakout strategy
double Res  = 0.0;                                         // this is for 'resistance' level for breakout strategy


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()  {

   int  Ticket;                                            // Order number

   double SL;                                              // SL of a selected order
   double TP;                                              // Take profit
   
   bool Opn_B  = false;                                     // Criterion for opening Buy
   bool Opn_S  = false;                                     // Criterion for opening Sell


//////////////////////     Preliminary processing    /////////////////////
   if(Bars < MinBars)  {                                   ///////////////
      Alert("Not enough bars in the window. EA doesn't work.");
      return;                                              // Exit start()
   }
   
   if(Work==false)   {                                     // Critical error
      Alert("Critical error. EA doesnt work.");
      return;                                              // Exit start()
   }
   
   if(Period() != 15) Alert("Chart is not set to 15 Min. bars !");
   
   if(TimeToStr(Time[0], TIME_MINUTES) == ResetTime)  {
      TradeExecuted = false;     //Reset TradeExecuted flag
      firstrun = true;
   }
            
//--------------------------------------------------------------
//                                 Trading criteria
//--------------------------------------------------------------
   //criteria to open BUY    
   Print("IsTradingTime() = ",IsTradingTime());
   
   SetSupportResistance();
   if(IsTradingTime() && !TradeExecuted)   {  //
     if(Ask > Res) Opn_B = true;
     if(Bid < Sup) Opn_S = true;
   }
  
  
   // Opening orders
   while(true)   {                                         // Orders closing loop
     
      // BUY ORDER
      if (Opn_B==true)    {                                // if Open BUY flag is true...execute order...
                                                           
         RefreshRates();                                   // Refresh rates
         
         SL = Bid - StopLoss * Point;                      // stop loss
         
         TP = Bid + TakeProfit * Point;                    // take profit
         
         Alert("Attempt to open Buy. Waiting for response...");
         
         Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, SL, TP, NULL, 0, 0, Blue);   //Opening Buy
         
         if (Ticket > 0)   {                               // Changed to > , Success :)
            Alert ("Opened order Buy ", Ticket);
            TradeExecuted = true;
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      
      //SELL ORDER
      if (Opn_S==true)   {                                 // if Open SELL flag is true...execute order...
                                                           
         RefreshRates();                                   // Refresh rates
         
         SL = Ask + StopLoss   * Point;                    // Calculating SL of opened
         
         TP = Ask - TakeProfit * Point;                    // Calculating TP of opened

         Alert("Attempt to open Sell. Waiting for response...");
         
         Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, SL, TP, NULL, 0, 0, Red);   //Opening Sell
         
         if (Ticket > 0)   {                               // changed to >,   Success :)
           
            Alert ("Opened order Sell ",Ticket);
            TradeExecuted = true;
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying

         return;                                           // Exit start()
      }
      
      break;                                               // Exit while loop
   }                                                       // close while loop
   
   return;                                                 // Exit start()
}                                                          // close start()


//--------------------------------------------------------------
//                  Error Handling Function: Fun_Error()       |
//--------------------------------------------------------------
int Fun_Error(int Error)   {                               // Function of processing errors

   switch(Error)   {                                       // Not crucial errors
   
      case 4: Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                                      // Simple solution
         return(1);                                        // Exit the function
         
      case 135:Alert("Price changed. Trying once again..");
         RefreshRates();                                   // Refresh rates
         return(1);                                        // Exit the function
         
      case 136:Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)                      // Till a new tick
            Sleep(1);                                      // Pause in the loop
         return(1);                                        // Exit the function
         
      case 137:Alert("Broker is busy. Trying once again..");
         Sleep(3000);                                      // Simple solution
         return(1);                                        // Exit the function

      case 146:Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                                       // Simple solution
         return(1);                                        // Exit the function
         
         // Critical errors /////////////////////////////////
      case 2: Alert("Common error.");
         return(0);                                        // Exit the function
      
      case 5: Alert("Old terminal version.");
         Work=false;                                       // Terminate operation
         return(0);                                        // Exit the function

      case 64: Alert("Account blocked.");
         Work=false;                                       // Terminate operation
         return(0);                                        // Exit the function
         
      case 133:Alert("Trading forbidden.");
         return(0);                                        // Exit the function

      case 134:Alert("Not enough money to execute operation.");
         return(0);                                        // Exit the function

      default: Alert("Error occurred: ",Error);            // Other variants
         return(0);                                        // Exit the function
   }                                                       // close switch statement
}                                                          // close Fun_Error() function


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()   {
   Alert("This EA is for testing and Educational purposes Only!" + "\n" +
         "It is intended for the GBP/USD pair on a 15 Min. Chart" + "\n" + 
         "Set From\To times to reflect when your brokers time" + "\n"+
         "coresponds to 7–9AM NY (1200-1400 UK time)"  + "\n" +
         "it is a one-shot EA that sends a fixed TP and SL w/ order" );
   start(); //for debugging purposes only     
   return(0);
}


//+------------------------------------------------------------------+
//|   SetSupportResistance() function definition                     |
//+------------------------------------------------------------------+
bool SetSupportResistance()   {
      if( TimeToStr(Time[0],TIME_MINUTES) == SR_Levels_To_Time   && firstrun)   {
         for(int i = 0; i < Iterations; i++)  {
            if(Low[i+1]  < Sup)  Sup = Low[i+1];
            if(High[i+1] > Res)  Res = High[i+1];
            Print("Sup = ", Sup,"  Res = ", Res, " TimeStamp[",i+1,"] = ", TimeToStr(Time[i+1], TIME_MINUTES) );
         }
         firstrun = false;
         return(true);
      }
   return(false);
}


//+------------------------------------------------------------------+
//|          IsTradingTime() function definition                     |
//+------------------------------------------------------------------+
bool IsTradingTime()   {
   if( StrToTime(TimeToStr(TimeCurrent(), TIME_MINUTES)) <  StrToTime(Stop_Trading_Time) )   {
      return(true);
   }
   return(false);
}


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
   return(0);
}