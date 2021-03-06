//AZ_EA_FMSWBBO_FIRMXMMF.mq4
//+------------------------------------------------------------------+
//|                                    Aharon_book_Tradingexpert.mq4 |
//|                                                          Aharon. |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon."
#property link      "http://www.anitani.net"

//---- input parameters
//--------------------------------------------------------------- 1 --
                                                           // Numeric values for M15
extern double StopLoss   = 20;                             // SL for an opened order
extern double TakeProfit = 30;                             // for an opened order
extern double ThldDecimal = 1.0;                           // for signal1
extern double BandsDeviations=2.0;                         // for signal1
extern double Lots       = 0.0;                           // Strictly set amount of lots   ...do not change this for now, 'tilllots calculation is verified to work
extern double Prots      = 0.02;                           // Percent of free margin 

extern int    TF1        = PERIOD_M15;                      // Time Frame for signal1 - this overrules chart Time Frame!
extern int    Slippage   = 2;
extern int    BandsPeriod=20;                              // for signal1

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
   S1,                                                     // Entry signal
   S2;                                                     // Exit signal
   
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
            Alert("Pending order detected. EA doesn't work.");
            return;                                        // Exit start()
         }
         
         Total++;                                          // Counter of market orders
         
         if (Total>1)   {                                  // < changed to >   No more than one order
            Alert("Several market orders. EA doesn't work.");
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
   S1   =   iCustom(NULL, TF1, "Aharon_FMSlopeWBBOrdered", BandsDeviations, BandsPeriod, ThldDecimal, 0, 0);
                                                           /*Aharon_FMSlopeWBBOrdered Parameters:
                                                             double BandsDeviations=2.0;
                                                             int    BandsPeriod=20;
                                                             double ThldDecimal = 1.0;
                                                           */
   
   
   S2   =   iCustom(NULL, TF1, "Aharon_FIRMXMMF", 
                     0, 20, 21, 4, 3, 0, 3, 2, 0, 2,       //parameters as listed below
                     3, 0);                                //Mode =3 is square wave signal, shift=o is no shifting of indicator 
                                                           /*int    TF1 = 0;       
                                                             int    Period1 = 20;
                                                             int    Taps1   = 21;     //must be odd number
                                                             int    Window1   = 4;
                                                             int    MA1Period = 2;
                                                             int    MA1shift = 0;
                                                             int    MA1method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                             int    MA2Period = 2;
                                                             int    MA2shift = 0;
                                                             int    MA2method   = 2;  //0=SMA, 1=EMA, 2=SMMMA, 3=LWMA
                                                           */
                                                           
   if (S1 == 1.0 && Total==0)     {                   // if flat and signal up;                           
      Opn_B=true;
   }
   
   if (S1 == -1.0 && Total==0)     {                  // if flat and signal down;                           
      Opn_S=true;                                          // Criterion for opening Sell
   }
     
   if (S2 == 1.0 && Total > 0  && Tip == 1)   {      // if S2 is up (close sell), and position exists, and it is a sell type
      Cls_S=true;                                          // Criterion for closing Sell, and
   }
   
   if (S2 == -1.0 && Total > 0  && Tip == 0)   {      // if S2 is dn (close buy), and position exists, and it is a buy type
      Cls_B=true;                                          // Criterion for closing Buy
   }
      
//----------------// Closing orders
   while(true)   {                                         // Loop of closing orders
     
      if (Tip==0 && Cls_B==true)  {                        // Order Buy is open, and there is criterion to close
      
         Alert("Attempt to close Buy ",Ticket,". Waiting for response..");
         
         RefreshRates();                                   // Refresh rates
         
         Ans = OrderClose(Ticket,Lot,Bid, Slippage, LightBlue);    // Closing Buy
         
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
         
         Ans = OrderClose(Ticket, Lot, Ask, Slippage, LightPink); // Closing Sell
         
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
   if (Lots > 0)                                           // < changed to >   If lots are set,      ... at this stage work strictly with one micro-lot
     
      Lts = Lots;                                          // work with them
   
   else                                                    // else, use % of free margin             ... need to verify this works correctly with micro lots, kelly etc.
         Lts = MathFloor(Free*Prots/One_Lot/Step)*Step;       // For opening
   if(Lts < Min_Lot) Lts=Min_Lot;               // > changed to <    Not less than minimal
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
   if (Lts*One_Lot > Free)  {                              // Lot larger than free margin
      Alert(" Not enough money for ", Lts," lots");
      return;                                   // Exit start()
   }
   
//--------------------------------------------------------------- 8 --
   
   // Opening orders
   while(true)   {                                         // Orders closing loop
     
      if (Total==0 && Opn_B==true)    {                    // No new orders +
                                                           // criterion for opening Buy
         RefreshRates();                                   // Refresh rates
         
         SL = Bid - New_Stop(StopLoss) * Point;            // Calculating SL not to be less than minimum allowed
         
         TP = Bid + New_Stop(TakeProfit) * Point;          // Calculating TP of opened not to be less than minimum allowed
         
         Alert("Attempt to open Buy. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_BUY, Lts, Ask, Slippage, SL, TP, NULL, 0, 0, Blue);   //Opening Buy
         
         if (Ticket > 0)   {                               // Changed to > , Success :)
            Alert ("Opened order Buy ", Ticket);
            return;                                        // Exit start()
         }
         
         if (Fun_Error(GetLastError())==1)                 // Processing errors
            continue;                                      // Retrying
         
         return;                                           // Exit start()
      }
      
      if (Total==0 && Opn_S==true)   {                     // No opened orders +
                                                           // criterion for opening Sell
         RefreshRates();                                   // Refresh rates
         
         SL = Ask + New_Stop(StopLoss)*Point;              // Calculating SL of opened
         
         TP = Ask - New_Stop(TakeProfit)*Point;            // Calculating TP of opened

         Alert("Attempt to open Sell. Waiting for response..");
         
         Ticket = OrderSend(Symb, OP_SELL, Lts, Bid, Slippage, SL, TP, NULL, 0, 0, Red);   //Opening Sell
         
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