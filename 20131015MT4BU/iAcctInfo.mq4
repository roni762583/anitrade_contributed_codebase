//+------------------------------------------------------------------+
//|                                                    iAcctInfo.mq4 |
//|                            Copyright 2012, Yehuda Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
//to display account info as comment on chart 
#property copyright "Copyright 2012, Yehuda Software Corp."
#property link      ""

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   Comment("iAcctInfo.mq4" + "\n" +  
           "Balance          " + AccountBalance() + "\n" +
           "Company          " + AccountCompany() + "\n" +
           "Credit           " + AccountCredit() + "\n" +
           "Currency         " + AccountCurrency() + "\n" +
           "Equity           " + AccountEquity() + "\n" +      //useful
           "Free Margin      " + AccountFreeMargin() + "\n" +  //useful
           "Free Margin Mode " + AccountFreeMarginMode() + "\n" +  //useful
           "Free Leverage    " + AccountLeverage() + "\n" +  //useful
           "Margin           " + AccountMargin() + "\n" +  //useful
           "Name             " + AccountName() + "\n" +  
           "Number           " + AccountNumber() + "\n" + 
           "Profit           " + AccountProfit() + "\n" +  //useful
           "Server           " + AccountServer() + "\n" +
           "Stopout Level    " + AccountStopoutLevel() + "\n" + 
           "Stopout Mode     " + AccountStopoutMode() + "\n" +
           "\n" +
           "Spread     " + MarketInfo(Symbol(),MODE_SPREAD) + "\n" +
           "");
//----
   return(0);
  }
//+------------------------------------------------------------------+