//+------------------------------------------------------------------+
//|                                    a_EA_book_RSI.mq4
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon."
#property link      "http://www.anitani.net"

//---- input parameters
//--------------------------------------------------------------- 1 --
                                                           // Numeric values for M15
extern double StopLoss   = 1000;                             // SL for an opened order
extern double TakeProfit = 1000;                             // for an opened order
extern int    RSIperiod  = 14;
extern int    RSIappliedPrice = PRICE_CLOSE;
extern double MaxPercentLots = 1;
extern double Lots       = 0.01;                           // Strictly set amount of lots   ...do not change this for now, 'tilllots calculation is verified to work
extern double Prots      = 0.02;                           // Percent of free margin 


bool Work = true;                                          // EA will work.

string Symb;                                               // Security name - from chart Window 

int MinBars = 50;                                          // this is minimum number of bars needed in a chart to operate for MA's, etc. Arb. # for now
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()  {
   int
   Total,                                                  // Amount of orders in a window
   Tip=-1,                                                 // Type of selected order (B=0,S=1)
   Ticket;                                                 // Order number

   double
   Lot,                                                    // Amount of lots in a selected order
   Lts,                                                    // Amount of lots in an opened order
   Min_Lot,                                                // Minimal amount of lots
   Step,                                                   // Step of lot size change
   Free,                                                   // Current free margin
   One_Lot,                                                // Price of one lot
   Price,                                                  // Price of a selected order
   SL,                                                     // SL of a selected order
   TP,                                                     // TP \u0437\u0430 a selected order
   signal1,                                                // signal from iCustom()
   signal0;
   
   bool
   Ans =false,                                             // Server response after closing
   Cls_B=false,                                            // Criterion for closing Buy
   Cls_S=false,                                            // Criterion for closing Sell
   Opn_B=false,                                            // Criterion for opening Buy
   Opn_S=false;                                            // Criterion for opening Sell
//--------------------------------------------------------------- 3 --

// Preliminary processing
   if(Bars < MinBars)  {                                   // Not enough bars - have to manually check it is enough in chart of called TF supeceeding chart TF
     
      Alert("Not enough bars in the window. EA doesn't work.");
      return;                                              // Exit start()
   }
   
   if(Work==false)   {                                     // Critical error
     
      Alert("Critical error. EA doesn't work.");
      return;                                              // Exit start()
   }

//--------------------------------------------------------------- 4 --
// Orders accounting
   Symb=Symbol();                                          // Security name from chart window 
   Total=0;                                                // Amount of orders
   for(int i=1; i<=OrdersTotal(); i++)   {                 // Loop through orders
         
      if (OrderSelect(i-1,SELECT_BY_POS)==true)   {        // If there is the next one
                                                           // Analyzing orders:
         if (OrderSymbol()!=Symb) continue;                // Another security
         
         if (OrderType()>1)   {                            // Pending order found, 
         
                                                           /* OP_BUY 0 Buying position. 
                                                              OP_SELL 1 Selling position. 
                                                              OP_BUYLIMIT 2 Buy limit pending position. 
                                                              OP_SELLLIMIT 3 Sell limit pending position. 
                                                              OP_BUYSTOP 4 Buy stop pending position. 
                                                              OP_SELLSTOP 5 Sell stop pending position. 
                                                           */
            Alert("Pending order detected.");// EA doesnt work.");
            return;                                        // Exit start()
         }
         
         Total++;                                          // Counter of market orders
         
         if (Total>1)   {                                  // < changed to >   No more than one order
            Alert("Several market orders.");// EA doesnt work.");
            return;                                        // Exit start()
         }                                                                                                           

         Ticket=OrderTicket();                             // Number of selected order
         Tip   =OrderType();                               // Type of selected order
         Price =OrderOpenPrice();                          // Price of selected order
         SL    =OrderStopLoss();                           // SL of selected order
         TP    =OrderTakeProfit();                         // TP of selected order
         Lot   =OrderLots();                               // Amount of lots
        
      }                                                    // close first if statement
   }                                                       // close for loop
//--------------------------------------------------------------- 5 --////////////////////
// Trading criteria
   
   signal0 = iRSI(Symbol(), Period(), RSIperiod, RSIappliedPrice, 0);
   signal1 = iRSI(Symbol(), Period(), RSIperiod, RSIappliedPrice, 1);
   if (signal0>70 && signal1<70)     {                   // if flat and signal up;                           
      Opn_S=true;  
      //Cls_B=true;                                        // Criterion for opening Buy
   }
   
   if (signal0<30 && signal1>30)     {                  // if flat and signal down;                           
      Opn_B=true; 
    //  Cls_B=true;                                         // Criterion for opening Sell
   }
   
   if (  (signal0<=50 && signal1>=50) || (signal0>=50 && signal1<=50)  )     {                  // if flat and signal down;                           
      Cls_S=true; 
      Cls_B=true;                                         // Criterion for opening Sell
   }
    
//----------------// Closing orders
   while(true)   {                                         // Loop of closing orders
     
      if (Tip==0 && Cls_B==true)  {                        // Order Buy is open, and there is criterion to close
      
         Alert("Attempt to close Buy ",Ticket,". Waiting for response..");
         
         RefreshRates();                                   // Refresh rates
         
         Ans = OrderClose(Ticket,Lot,Bid,2, LightBlue);    // Closing Buy
         
         if (Ans==true)    {                               // Success :)
           
            Alert ("Closed order Buy ", Ticket);
            break;                                         // Exit closing while loop
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      if (Tip==1 && Cls_S==true)   {                       // Order Sell is open, and there is criterion to close
      
         Alert("Attempt to close Sell ", Ticket, ". Waiting for response..");
         
         RefreshRates();                                   // Refresh rates
         
         Ans = OrderClose(Ticket, Lot, Ask, 2, LightPink); // Closing Sell
         
         if (Ans==true)   {                                // Success :)
           
            Alert ("Closed order Sell ",Ticket);
            
            break;                                         // Exit closing loop
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      break;                                               // Exit while
   }

//////////////pg. 250 starts below

//--------------------------------------------------------------- 7 --
   // Order value
   RefreshRates();                                         // Refresh rates
   
   Min_Lot = MarketInfo(Symb, MODE_MINLOT);                // Minimal number of lots

   Free    = AccountFreeMargin();                          // Free margin
   
   One_Lot = MarketInfo(Symb, MODE_MARGINREQUIRED);        // Price of 1 lot //this is price for full lot, whereas min-lot may be 0.01

   Step    = MarketInfo(Symb, MODE_LOTSTEP);               // Step is changed
   
   /////////////////////THIS NEEDS WORK TO CONFIRM PROPER FUNCTIONING OF CALCULATION, AND INCORPORATING KELLY CRITERION
   //                            FOR NOW WORK STRICTLY WITH 0.01 LOTS, THE MINIMUM
   //if (Lots > 0)                                           // < changed to >   If lots are set,      ... at this stage work strictly with one micro-lot
     
      Lts = Lots;                                          // work with them
   
   //else                                                    // else, use % of free margin             ... need to verify this works correctly with micro lots, kelly etc.
   //      Lts = MathFloor(Free*Prots/One_Lot/Step)*Step;       // For opening
   //if(Lts < Min_Lot) Lts=Min_Lot;               // > changed to <    Not less than minimal
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
   if (Lts*One_Lot > Free)  {                              // Lot larger than free margin
      Alert(" Not enough money for ", Lts," lots");
      return;                                   // Exit start()
   }
   
//--------------------------------------------------------------- 8 --
   
   // Opening orders
   while(true)   {                                         // Orders closing loop
     
      if ( Opn_B==true)    {                    // No new orders +Total==0 &&
                                                           // criterion for opening Buy
         RefreshRates();                                   // Refresh rates
         
         SL = Bid - New_Stop(StopLoss) * Point;            // Calculating SL not to be less than minimum allowed
         
         TP = Bid + New_Stop(TakeProfit) * Point;          // Calculating TP of opened not to be less than minimum allowed
         
         Alert("Attempt to open Buy. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_BUY, Lts, Ask, 2, SL, TP, NULL, 0, 0, Blue);   //Opening Buy
         
         if (Ticket > 0)   {                               // Changed to > , Success :)
            Alert ("Opened order Buy ", Ticket);
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      if (  Opn_S==true)   {                     // No opened orders +Total==0
                                                           // criterion for opening Sell
         RefreshRates();                                   // Refresh rates
         
         SL = Ask + New_Stop(StopLoss)*Point;              // Calculating SL of opened
         
         TP = Ask - New_Stop(TakeProfit)*Point;            // Calculating TP of opened

         Alert("Attempt to open Sell. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_SELL, Lts, Bid, 2, SL, TP, NULL, 0, 0, Red);   //Opening Sell
         
         if (Ticket > 0)   {                               // changed to >,   Success :)
           
            Alert ("Opened order Sell ",Ticket);
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying

         return;                                           // Exit start()
      }
      
      break;                                               // Exit while
   }                                                       // close while loop
   
//--------------------------------------------------------------- 9 --
/////////////////pg 251 starts below:
   return;                                                 // Exit start()
}                                                          // close start()

//-------------------------------------------------------------- 10 --

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

//-------------------------------------------------------------- 11 --

int New_Stop(int Parametr)   {                             // Checking stop levels
   
   int Min_Dist = MarketInfo(Symb, MODE_STOPLEVEL);        // Minimal distance
   
   if (Parametr < Min_Dist)   {                            // (CHANGED TO <) If manually set value is less than min. allowed stop distance,
      Parametr = Min_Dist;                                 // Set stop level to min. allowed instead
      Alert("Increased distance of stop level. New dist. set = ", Parametr);
   }
   
   return(Parametr);                                       // Returning value
}                                                          // close New_Stop() function

//-------------------------------------------------------------- 12 --


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()   {
//----
//   start();                                              //this is to initiate EA when not connected to server for testing purposes
//----
   return(0);
}


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()  {
//----
   
//----
   return(0);
}

//+------------------------------------------------------------------+