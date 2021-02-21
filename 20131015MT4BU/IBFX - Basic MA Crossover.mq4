#property copyright "Interbank FX, LLC"
#property link      "http://www.ibfx.com"
#include <stderror.mqh> 
//+------------------------------------------------------------------+
//| Global Variables / Includes                                      |
//+------------------------------------------------------------------+
datetime   CurrTime = 0;
datetime   PrevTime = 0;
  string        Sym = "";
     int  TimeFrame = 0;
     int      Shift = 1;
     int  SymDigits = 5;
  double  SymPoints = 0.0001;
  
     int MA1ArraySelected = 0;
     int MA2ArraySelected = 0;
     int MA1MethodSelected = 0;
     int MA2MethodSelected = 0;
//+------------------------------------------------------------------+
//| Expert User Inputs                                               |
//+------------------------------------------------------------------+
extern bool   UseCompletedBars = true;

// Create any user input for the indicators you will use here
// For example:
extern string MA1Array   = "Close";
extern string MA2Array   = "Close";
extern int    MA1Periods = 12;
extern int    MA2Periods = 26;
extern string MA1Method  = "Simple";
extern string MA2Method  = "Simple";

extern double         Lots = 0.01;
extern    int  MagicNumber = 1235;
extern    int ProfitTarget =  100; 
extern    int     StopLoss =  100; 
extern    int     Slippage =    3;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
         Sym = Symbol();
   TimeFrame = Period();   
   SymPoints = MarketInfo( Sym, MODE_POINT  );
   SymDigits = MarketInfo( Sym, MODE_DIGITS );
   //---
        if( SymPoints == 0.001   ) { SymPoints = 0.01;   SymDigits = 3; }
   else if( SymPoints == 0.00001 ) { SymPoints = 0.0001; SymDigits = 5; }
   
     //------------------ CLOSE -------------------------
       if(MA1Array == "C")      {MA1ArraySelected = PRICE_CLOSE;}
  else if(MA1Array == "CLOSE")  {MA1ArraySelected = PRICE_CLOSE;}
  else if(MA1Array == "Close")  {MA1ArraySelected = PRICE_CLOSE;}
  else if(MA1Array == "c")      {MA1ArraySelected = PRICE_CLOSE;}
  else if(MA1Array == "close")  {MA1ArraySelected = PRICE_CLOSE;}
  //------------------ LOW -------------------------
  else if(MA1Array == "L")    {MA1ArraySelected = PRICE_LOW;}
  else if(MA1Array == "LOW")  {MA1ArraySelected = PRICE_LOW;}
  else if(MA1Array == "Low")  {MA1ArraySelected = PRICE_LOW;}
  else if(MA1Array == "l")    {MA1ArraySelected = PRICE_LOW;}
  else if(MA1Array == "low")  {MA1ArraySelected = PRICE_LOW;}
  //------------------ HIGH -------------------------
  else if(MA1Array == "H")     {MA1ArraySelected = PRICE_HIGH;}
  else if(MA1Array == "HIGH")  {MA1ArraySelected = PRICE_HIGH;}
  else if(MA1Array == "High")  {MA1ArraySelected = PRICE_HIGH;}
  else if(MA1Array == "h")     {MA1ArraySelected = PRICE_HIGH;}
  else if(MA1Array == "high")  {MA1ArraySelected = PRICE_HIGH;}
  //------------------ OPEN-------------------------
  else if(MA1Array == "O")     {MA1ArraySelected = PRICE_OPEN;}
  else if(MA1Array == "OPEN")  {MA1ArraySelected = PRICE_OPEN;}
  else if(MA1Array == "Open")  {MA1ArraySelected = PRICE_OPEN;}
  else if(MA1Array == "o")     {MA1ArraySelected = PRICE_OPEN;}
  else if(MA1Array == "open")  {MA1ArraySelected = PRICE_OPEN;}
  //------------------ Typical -------------------------
  else if(MA1Array == "TYPICAL") {MA1ArraySelected = PRICE_TYPICAL;}
  else if(MA1Array == "Typical") {MA1ArraySelected = PRICE_TYPICAL;}
  else if(MA1Array == "typical") {MA1ArraySelected = PRICE_TYPICAL;}
  else if(MA1Array == "T")       {MA1ArraySelected = PRICE_TYPICAL;}
  else if(MA1Array == "t")       {MA1ArraySelected = PRICE_TYPICAL;}
  //------------------ MEDIAN -------------------------------
  else if(MA1Array == "MEDIAN") {MA1ArraySelected = PRICE_MEDIAN;}
  else if(MA1Array == "Median") {MA1ArraySelected = PRICE_MEDIAN;}
  else if(MA1Array == "median") {MA1ArraySelected = PRICE_MEDIAN;}
  else if(MA1Array == "M")      {MA1ArraySelected = PRICE_MEDIAN;}
  else if(MA1Array == "m")      {MA1ArraySelected = PRICE_MEDIAN;}
  //------------------ DEFAULT -------------------------------
  else                       
  {
   Alert("Please select a valid array in open, high, Low, Close, Typical, Median" );
   return(-1);
  }

     //------------------ CLOSE -------------------------
       if(MA2Array == "C")      {MA2ArraySelected = PRICE_CLOSE;}
  else if(MA2Array == "CLOSE")  {MA2ArraySelected = PRICE_CLOSE;}
  else if(MA2Array == "Close")  {MA2ArraySelected = PRICE_CLOSE;}
  else if(MA2Array == "c")      {MA2ArraySelected = PRICE_CLOSE;}
  else if(MA2Array == "close")  {MA2ArraySelected = PRICE_CLOSE;}
  //------------------ LOW -------------------------
  else if(MA2Array == "L")    {MA2ArraySelected = PRICE_LOW;}
  else if(MA2Array == "LOW")  {MA2ArraySelected = PRICE_LOW;}
  else if(MA2Array == "Low")  {MA2ArraySelected = PRICE_LOW;}
  else if(MA2Array == "l")    {MA2ArraySelected = PRICE_LOW;}
  else if(MA2Array == "low")  {MA2ArraySelected = PRICE_LOW;}
  //------------------ HIGH -------------------------
  else if(MA2Array == "H")     {MA2ArraySelected = PRICE_HIGH;}
  else if(MA2Array == "HIGH")  {MA2ArraySelected = PRICE_HIGH;}
  else if(MA2Array == "High")  {MA2ArraySelected = PRICE_HIGH;}
  else if(MA2Array == "h")     {MA2ArraySelected = PRICE_HIGH;}
  else if(MA2Array == "high")  {MA2ArraySelected = PRICE_HIGH;}
  //------------------ OPEN-------------------------
  else if(MA2Array == "O")     {MA2ArraySelected = PRICE_OPEN;}
  else if(MA2Array == "OPEN")  {MA2ArraySelected = PRICE_OPEN;}
  else if(MA2Array == "Open")  {MA2ArraySelected = PRICE_OPEN;}
  else if(MA2Array == "o")     {MA2ArraySelected = PRICE_OPEN;}
  else if(MA2Array == "open")  {MA2ArraySelected = PRICE_OPEN;}
  //------------------ Typical -------------------------
  else if(MA2Array == "TYPICAL") {MA2ArraySelected = PRICE_TYPICAL;}
  else if(MA2Array == "Typical") {MA2ArraySelected = PRICE_TYPICAL;}
  else if(MA2Array == "typical") {MA2ArraySelected = PRICE_TYPICAL;}
  else if(MA2Array == "T")       {MA2ArraySelected = PRICE_TYPICAL;}
  else if(MA2Array == "t")       {MA2ArraySelected = PRICE_TYPICAL;}
  //------------------ MEDIAN -------------------------------
  else if(MA2Array == "MEDIAN") {MA2ArraySelected = PRICE_MEDIAN;}
  else if(MA2Array == "Median") {MA2ArraySelected = PRICE_MEDIAN;}
  else if(MA2Array == "median") {MA2ArraySelected = PRICE_MEDIAN;}
  else if(MA2Array == "M")      {MA2ArraySelected = PRICE_MEDIAN;}
  else if(MA2Array == "m")      {MA2ArraySelected = PRICE_MEDIAN;}
  //------------------ DEFAULT -------------------------------
  else                       
  {
   Alert("Please select a valid array in open, high, Low, Close, Typical, Median" );
   return(-1);
  }
  //------------------ CLOSE -------------------------
       if(MA1Method == "Simple")  {MA1MethodSelected = MODE_SMA; }
  else if(MA1Method == "SIMPLE")  {MA1MethodSelected = MODE_SMA; }
  else if(MA1Method == "S")       {MA1MethodSelected = MODE_SMA; }
  else if(MA1Method == "s")       {MA1MethodSelected = MODE_SMA; }
  else if(MA1Method == "simple")  {MA1MethodSelected = MODE_SMA; }
  //------------------ LOW -------------------------
  else if(MA1Method == "Exponential") { MA1MethodSelected = MODE_EMA;}
  else if(MA1Method == "EXPONENTIAL") { MA1MethodSelected = MODE_EMA;}
  else if(MA1Method == "E")           { MA1MethodSelected = MODE_EMA;}
  else if(MA1Method == "e")           { MA1MethodSelected = MODE_EMA;}
  else if(MA1Method == "exponential") { MA1MethodSelected = MODE_EMA;}
  //------------------ DEFAULT -------------------------------
  else                       
  {
   Alert("Please select a valid Method: Simple or Exponential" );
   return(-1);
  }
  //------------------ CLOSE -------------------------
       if(MA2Method == "Simple")  {MA2MethodSelected = MODE_SMA; }
  else if(MA2Method == "SIMPLE")  {MA2MethodSelected = MODE_SMA; }
  else if(MA2Method == "S")       {MA2MethodSelected = MODE_SMA; }
  else if(MA2Method == "s")       {MA2MethodSelected = MODE_SMA; }
  else if(MA2Method == "simple")  {MA2MethodSelected = MODE_SMA; }
  //------------------ LOW -------------------------
  else if(MA2Method == "Exponential") { MA2MethodSelected = MODE_EMA;}
  else if(MA2Method == "EXPONENTIAL") { MA2MethodSelected = MODE_EMA;}
  else if(MA2Method == "E")           { MA2MethodSelected = MODE_EMA;}
  else if(MA2Method == "e")           { MA2MethodSelected = MODE_EMA;}
  else if(MA2Method == "exponential") { MA2MethodSelected = MODE_EMA;}
  //------------------ DEFAULT -------------------------------
  else                       
  {
   Alert("Please select a valid Method: Simple or Exponential" );
   return(-1);
  }
  
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() { return(0); }

//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
int start() 
{    
     int RealTime = 0;
     if( UseCompletedBars )
     {
      CurrTime = iTime(Sym, TimeFrame, 1 );
      if( CurrTime == PrevTime )
      {
         return(0);
      } 
      //---- Update Vars
      PrevTime = CurrTime;
      RealTime = 1;
     }
      
      //---- Need to chek for a new Signal?
      if( CountAll( Sym, MagicNumber) == 0)
      {
         //---- Indicator 1 Values
         double Indicator1CurrentValue  = iMA(NULL,0,MA1Periods,0,MA1MethodSelected, MA1ArraySelected,0+RealTime);
         double Indicator1PreviousValue = iMA(NULL,0,MA1Periods,0,MA1MethodSelected, MA1ArraySelected,1+RealTime);
         //---- Indicator 2 Values
         double Indicator2CurrentValue  = iMA(NULL,0,MA2Periods,0,MA2MethodSelected, MA2ArraySelected,0+RealTime);
         double Indicator2PreviousValue = iMA(NULL,0,MA2Periods,0,MA2MethodSelected, MA2ArraySelected,1+RealTime);
         
         //---- Moving Average Cross System
              if( Indicator1CurrentValue > Indicator2CurrentValue && Indicator1PreviousValue <= Indicator2PreviousValue ) { EnterLong(Sym, Lots, ""); }
         else if( Indicator1CurrentValue < Indicator2CurrentValue && Indicator1PreviousValue >= Indicator2PreviousValue ) { EnterShrt(Sym, Lots, ""); }
      }
      //----
   
   //----
   return(0); 
}

//+------------------------------------------------------------------+
//| Expert Custom Functions                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CountAll()                                                       |
//+------------------------------------------------------------------+
int CountAll( string Symbole, int Magic )
{
    //---- 
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if ( OrderMagicNumber() != Magic   ) continue;
        if (      OrderSymbol() != Symbole ) continue;
        
             if ( OrderType() == OP_BUY  ) { count++; }
        else if ( OrderType() == OP_SELL ) { count++; }
    }
    //----
    return(count);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Stop Long                                              |
//+------------------------------------------------------------------+
double StopLong(double price,double stop,double point,double SymDgts )
{
 if(stop==0) { return(0); }
 else        { return(NormalizeDouble( price-(stop*point),SymDgts)); }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Stop Short                                             |
//+------------------------------------------------------------------+
double StopShrt(double price,double stop,double point,double SymDgts )
{
 if(stop==0) { return(0); }
 else        { return(NormalizeDouble( price+(stop*point),SymDgts)); }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Profit Target Long                                     |
//+------------------------------------------------------------------+
double TakeLong(double price,double take,double point,double SymDgts )
{
 if(take==0) {  return(0);}
 else        {  return(NormalizeDouble( price+(take*point),SymDgts));}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Profit Target Long                                     |
//+------------------------------------------------------------------+
double TakeShrt(double price,double take,double point,double SymDgts )
{
 if(take==0) {  return(0);}
 else        {  return(NormalizeDouble( price-(take*point),SymDgts));}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Place Long Order                                                 |
//+------------------------------------------------------------------+
int EnterLong( string FinalSymbol, double FinalLots, string EA_Comment )
{
   int Ticket = -1; int err = 0; bool OrderLoop = False; int TryCount = 0;
                     
   while( !OrderLoop )
   {
      while( IsTradeContextBusy() ) { Sleep( 10 ); }
                           
      RefreshRates();
      double SymAsk = NormalizeDouble( MarketInfo( FinalSymbol, MODE_ASK ), SymDigits );    
      double SymBid = NormalizeDouble( MarketInfo( FinalSymbol, MODE_BID ), SymDigits );
                               
      Ticket = OrderSend( FinalSymbol, OP_BUY, FinalLots, SymAsk, 0, 0.0, 0.0, EA_Comment, MagicNumber, 0, CLR_NONE ); 
                           
      int Err=GetLastError();
      
      switch (Err) 
      {
           //---- Success
           case               ERR_NO_ERROR: OrderLoop = true; 
                                            if( OrderSelect( Ticket, SELECT_BY_TICKET ) )
                                            { OrderModify( Ticket, OrderOpenPrice(), StopLong(SymBid,StopLoss, SymPoints,SymDigits), TakeLong(SymAsk,ProfitTarget,SymPoints,SymDigits), 0, CLR_NONE ); }
                                            break;
     
           //---- Retry Error     
           case            ERR_SERVER_BUSY:
           case          ERR_NO_CONNECTION:
           case          ERR_INVALID_PRICE:
           case             ERR_OFF_QUOTES:
           case            ERR_BROKER_BUSY:
           case     ERR_TRADE_CONTEXT_BUSY: TryCount++; break;
           case          ERR_PRICE_CHANGED:
           case                ERR_REQUOTE: continue;
     
           //---- Fatal known Error 
           case          ERR_INVALID_STOPS: OrderLoop = true; Print( "Invalid Stops"    ); break; 
           case   ERR_INVALID_TRADE_VOLUME: OrderLoop = true; Print( "Invalid Lots"     ); break; 
           case          ERR_MARKET_CLOSED: OrderLoop = true; Print( "Market Close"     ); break; 
           case         ERR_TRADE_DISABLED: OrderLoop = true; Print( "Trades Disabled"  ); break; 
           case       ERR_NOT_ENOUGH_MONEY: OrderLoop = true; Print( "Not Enough Money" ); break; 
           case  ERR_TRADE_TOO_MANY_ORDERS: OrderLoop = true; Print( "Too Many Orders"  ); break; 
              
           //---- Fatal Unknown Error
           case              ERR_NO_RESULT:
                                   default: OrderLoop = true; Print( "Unknown Error - " + Err ); break; 
           //----                         
       }  
       // end switch 
       if( TryCount > 10) { OrderLoop = true; }
   }
   //----               
   return(Ticket);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Place Shrt Order                                                 |
//+------------------------------------------------------------------+
int EnterShrt( string FinalSymbol, double FinalLots, string EA_Comment )
{
   int Ticket = -1; int err = 0; bool OrderLoop = False; int TryCount = 0;
                     
   while( !OrderLoop )
   {
      while( IsTradeContextBusy() ) { Sleep( 10 ); }
                           
      RefreshRates();
      double SymAsk = NormalizeDouble( MarketInfo( FinalSymbol, MODE_ASK ), SymDigits );    
      double SymBid = NormalizeDouble( MarketInfo( FinalSymbol, MODE_BID ), SymDigits );
                               
      Ticket = OrderSend( FinalSymbol, OP_SELL, FinalLots, SymBid, 0,  0.0,0.0, EA_Comment, MagicNumber, 0, CLR_NONE ); 
                           
      int Err=GetLastError();
      
      switch (Err) 
      {
           //---- Success
                 case               ERR_NO_ERROR: OrderLoop = true;
                                                  if( OrderSelect( Ticket, SELECT_BY_TICKET ) )
                                                  { OrderModify( Ticket, OrderOpenPrice(), StopShrt(SymAsk,StopLoss, SymPoints,SymDigits), TakeShrt(SymBid,ProfitTarget, SymPoints,SymDigits), 0, CLR_NONE ); }
                                                  break;
     
           //---- Retry Error     
           case            ERR_SERVER_BUSY:
           case          ERR_NO_CONNECTION:
           case          ERR_INVALID_PRICE:
           case             ERR_OFF_QUOTES:
           case            ERR_BROKER_BUSY:
           case     ERR_TRADE_CONTEXT_BUSY: TryCount++; break;
           case          ERR_PRICE_CHANGED:
           case                ERR_REQUOTE: continue;
     
           //---- Fatal known Error 
           case          ERR_INVALID_STOPS: OrderLoop = true; Print( "Invalid Stops"    ); break; 
           case   ERR_INVALID_TRADE_VOLUME: OrderLoop = true; Print( "Invalid Lots"     ); break; 
           case          ERR_MARKET_CLOSED: OrderLoop = true; Print( "Market Close"     ); break; 
           case         ERR_TRADE_DISABLED: OrderLoop = true; Print( "Trades Disabled"  ); break; 
           case       ERR_NOT_ENOUGH_MONEY: OrderLoop = true; Print( "Not Enough Money" ); break; 
           case  ERR_TRADE_TOO_MANY_ORDERS: OrderLoop = true; Print( "Too Many Orders"  ); break; 
              
           //---- Fatal Unknown Error
           case              ERR_NO_RESULT:
                                   default: OrderLoop = true; Print( "Unknown Error - " + Err ); break; 
           //----                         
       }  
       // end switch 
       if( TryCount > 10) { OrderLoop = true; }
   }
   //----               
   return(Ticket);
}
//+------------------------------------------------------------------+