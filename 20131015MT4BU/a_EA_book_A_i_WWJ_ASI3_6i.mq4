//+------------------------------------------------------------------+
//|                                    a_EA_book_A_i_WWJ_ASI3_6i.mq4 |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon."
#property link      "http://www.anitani.net"

//---- 11/06/2011 modified
                                                           // Numeric values for M15
extern double StopLoss   = 1000;                            // SL for an opened order
extern double TakeProfit = 1000;                            // for an opened order
extern double Lots       = 0.1;                            // Strictly set amount of lots   ...do not change this for now, 'tilllots calculation is verified to work
extern int    magic      = 762258;



bool Work = true;                                          // EA will work.

string Symb;                                               // Security name - from chart Window 

int MinBars = 50;                                          // this is minimum number of bars needed in a chart to operate for MA's, etc. Arb. # for now


int start()  {
   newBar();
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


   if(Bars < MinBars)  {                                   // Not enough bars
      Alert("Not enough bars in the window. EA doesnt work.");
      return;                                              // Exit start()
   }

   
   if(Work==false)   {                                     // Critical error     
      Alert("Critical error. EA doesnt work.");
      return;                                              // Exit start()
   }
   

// Trading criteria

   signal0 = iCustom(Symb, Period(), "A_i_WWJ_ASI3_6i", 300, 0, 0);
   signal1 = iCustom(Symb, Period(), "A_i_WWJ_ASI3_6i", 300, 0, 1);
   
   if (signal0==1 /*&& signal1==0*/ && isFlat())     {     // if sig. just turned up, and position is flat
      Opn_B=true;                                          // flag to open buy position
       Print("Opn_B flagged");
   }
   
   if (signal0==-1 /*&& signal1==0*/ && isFlat())    {     // if sig. just turned down, and position is flat
      Opn_S=true;                                          // flag to open short position
       Print("Opn_S flagged");
   }
   
   if ( newBar() && signal1==0 && !isFlat())   {           // if newBar, and signal on prev. bar is OFF, and is NOT flat, then, flatten position
      Cls_S=true; 
      Cls_B=true;                                          // Criterion for closing orders 
   }
    

// Closing orders
   if (Cls_B==true)  {                                              // if criterion to close BUY order...
      Symb=Symbol();                                                // Security name from chart window 
      for(int i=1; i<=OrdersTotal(); i++)   {                       // Loop through orders
         if (OrderSelect(i-1,SELECT_BY_POS) == true &&              // if OrderSelect() succeeded
             OrderSymbol() == Symb &&                               // and is for this symbol 
             OrderMagicNumber() == magic &&                         // and has this magic number
             OrderCloseTime() == 0 &&                               // and is open or pending order
             OrderType() == OP_BUY)   {                             // and is of BUY type
                Alert("Attempt to close Buy ",OrderTicket());       // alert 
                while(true)   { 
                   RefreshRates();                                  // Refresh rates
                   Ans = OrderClose(OrderTicket(), OrderLots(), Bid, 2, LightBlue);// Closing Buy
                   if(Ans!=true)   {                                // if close did not go through
                      if (Fun_Error(GetLastError())==1)             // Processing errors, if returns 1, retry, not fatal
                      continue;                                     // continue to next itteration of while loop to retry to close
                   } // close if(Ans!=
                   if (Ans==true)  {                                // if OrderClose() succeeded
                      Alert ("Closed Buy order ", Ticket);
                      break;                                        // exit out of while(true) loop
                   } // close if(Ans==...)
                }  // close while(true)...
                return;                                             // Exit start()
         } //close if(OrderSelect(.....
      }  //close for loop 
   } //close if(Cls_B....


   if(Cls_S == true)  {                                                    // if criterion to close SELL order...
      Symb=Symbol();                                                // Security name from chart window 
      for(i=1; i<=OrdersTotal(); i++)   {                       // Loop through orders
         if(OrderSelect(i-1,SELECT_BY_POS) == true &&              // if OrderSelect() succeeded
            OrderSymbol() == Symb &&                               // and is for this symbol 
            OrderMagicNumber() == magic &&                         // and has this magic number
            OrderCloseTime() == 0 &&                               // and is open or pending order
            OrderType() == OP_SELL)   {                            // and is of SELL type
               Alert("Attempt to close Short ",OrderTicket());     // alert 
               while(true)   {
                  RefreshRates();                                  // Refresh rates
                  Ans = OrderClose(OrderTicket(), OrderLots(), Ask, 2, Red);      // Closing SELL
                  if(Ans!=true)   {                                // if close did not go through
                     if (Fun_Error(GetLastError())==1)             // Processing errors, if returns 1, retry, not fatal
                        continue;                                  // continue to next itteration of while loop to retry to close
                  } // close if(Ans!=
                  if(Ans==true)  {                                // if OrderClose() succeeded
                     Alert ("Closed Sell order ", Ticket);
                     break;                                        // exit out of while(true) loop
                  } // close if(Ans==...)
               } // close while(true)...
               return;                                             // Exit start()
         } //close if(OrderSelect(.....
      } //close for loop 
   } //close if(Cls_S==....


// Opening Orders
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
   while(true)   {
     if(Opn_B==true)  {
        RefreshRates();                                    // Refresh rates
        SL = Bid - New_Stop(StopLoss)   * Point;           // Calculating SL not to be less than minimum allowed
        TP = Ask + New_Stop(TakeProfit) * Point;           // Calculating TP of opened not to be less than minimum allowed
        Alert("Attempt to open Buy. Waiting for response..");
        Ticket = OrderSend(Symb, OP_BUY, Lts, Ask, 2, 0, 0, NULL, magic, 0, Blue);   //Opening Buy //SL TP from OrderSend()
        if(Ticket > 0)  {                                  // Changed to > , Success :)
           Alert ("Opened order Buy ", Ticket);
           return;                                         // Exit start()
        }
        if(Fun_Error(GetLastError())==1)                   // Processing errors
           continue;                                       // Retrying
      } // close if(Opn_B==...
      return;                                              // return from start(), i.e. Opn_B!=true 
   } //close while() loop
   
  
   
   while(true)   {
     if(Opn_S==true)   {                                   // No opened orders
         Print(" Opn_S is true");
         RefreshRates();                                   // Refresh rates
         SL = Ask + New_Stop(StopLoss)   * Point;          // Calculating SL not to be less than minimum allowed
         TP = Bid - New_Stop(TakeProfit) * Point;          // Calculating TP of opened not to be less than minimum allowed
         Alert("Attempt to open Sell. Waiting for response..");
         Ticket = OrderSend(Symb, OP_SELL, Lts, Bid, 2, 0/*SL*/, 0/*TP*/, NULL, magic, 0, Red);   //Opening Sell
         if(Ticket > 0)  {                                 // Changed to > , Success :)
           Alert ("Opened Sell order ", Ticket);
           return;                                         // Exit start()
        }
        if(Fun_Error(GetLastError())==1)                   // Processing errors
           continue;                                       // Retrying
     } // close if(Opn_S==...
     return;                                               // return from start(), i.e. Opn_B!=true 
   } // close while() loop
   return;                                                 // Exit start()
}                                                          // close start()


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
   if (Parametr < Min_Dist)   {                            // if manually set value is less than min. allowed stop distance,
      Parametr = Min_Dist;                                 // Set stop level to min. allowed instead
      Alert("Increased distance of stop level. New dist. set = ", Parametr);
   }
   return(Parametr);                                       // Returning value
} // close New_Stop() function


int init()   {
// start();                                                //this is to initiate EA when not connected to server for testing purposes
   return(0);
}


int deinit()  {
   return(0);
}


bool newBar()   {
   static datetime New_Time=0;                             // Time of the current bar   
   if(New_Time!=Time[0])   {                               // Compare time
      New_Time=Time[0];                                    // Now time is so
     // Print("new bar detected, having time ", TimeToStr(New_Time, TIME_MINUTES));
      return(true);                                        // A new bar detected
   }
   return(false);
} 


bool isFlat()   {
   Symb=Symbol();                                          // Security name from chart window 
   for(int i=1; i<=OrdersTotal(); i++)   {                 // Loop through orders
      if (OrderSelect(i-1,SELECT_BY_POS) == true &&        // if OrderSelect() succeeded
          OrderSymbol() == Symb &&                         // and is for this symbol 
          OrderMagicNumber() == magic &&                   // and has this magic number
          OrderCloseTime() == 0                            // and is open or pending order (can further be distinguished by OrderType()
         )   {
         //Print("is not flat");   // print order info
         return(false);
         }  //close if()
   } //close for loop  
   return(true);  
} //close function