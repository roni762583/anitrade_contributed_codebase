//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//| Expert User Inputs                                               |
//+------------------------------------------------------------------+
extern   bool   UseCompletedBars = true;

extern int PeriodsK = 14;
extern int PeriodsD = 3;
extern int PeriodsSmoothD = 3;

extern int LowLevel = 20;
extern int HighLevel = 80;

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
         double Stoch1 = iStochastic(NULL,0,PeriodsK,PeriodsD,PeriodsSmoothD,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0+RealTime);
         double Stoch2 = iStochastic(NULL,0,PeriodsK,PeriodsD,PeriodsSmoothD,MODE_EMA,PRICE_CLOSE,MODE_MAIN,1+RealTime);
         double    ma1 = iStochastic(NULL,0,PeriodsK,PeriodsD,PeriodsSmoothD,MODE_EMA,PRICE_CLOSE,MODE_SIGNAL,0+RealTime);
         double    ma2 = iStochastic(NULL,0,PeriodsK,PeriodsD,PeriodsSmoothD,MODE_EMA,PRICE_CLOSE,MODE_SIGNAL,1+RealTime);

              if( Stoch1 > LowLevel  && Stoch2 < LowLevel  ){ EnterLong(Sym, Lots, ""); }
         else if( Stoch1 < HighLevel && Stoch2 > HighLevel ){ EnterShrt(Sym, Lots, ""); }
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