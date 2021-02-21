
#property copyright "Copyright © 2009, FX Equity Builder"
#property link      "FX Equity Builder.com"

int g_period_76 = 28;
int g_period_80 = 6;
int g_slowing_84 = 14;
int g_timeframe_88 = PERIOD_M5;
int g_timeframe_92 = PERIOD_M5;
int g_shift_96 = 1;
int gi_100 = 80;
int gi_104 = 20;
int gi_108 = 1;
int gi_112 = 2;
bool gi_116 = FALSE;
int g_period_120 = 3;
int g_timeframe_124 = PERIOD_D1;
string gs_unused_128 = "--TRADE SETTING--";
extern bool ShowStatus = False;
extern string SystemSettings;
extern int AccountType = 2;
extern double Lots = 0.01;
extern int TakeProfit = 10;
bool gi_unused_160 = FALSE;
double gd_unused_164 = 50.0;
extern double Multi = 1.5;
extern int MaxTrades = 8;
extern int Pips = 10;
extern int StopLoss = 0;
int gi_192 = 0;
int gi_196 = 1;
extern int Risk = 2;
string gs_unused_204 = "0=1.0(standard), 1=0.10(mini), 2=0.01(micro)";
string gs_unused_212 = "--MAgic No--";
extern int MagicNumber = 333666;
extern int MagicNumber2 = 333667;
string gs_unused_224 = "";
bool gi_unused_232 = FALSE;
string gs_unused_236 = "";
int gi_unused_244 = 22;
string gs_unused_248 = "";
int gi_unused_256 = 3;
string gs_unused_260 = "";
bool gi_268 = FALSE;
string gs_unused_272 = "if true, then the expert will protect the account equity to the percent specified";
extern bool EquityProtection = FALSE;
string gs_unused_284 = "percent of the account to protect on a set of trades";
extern int EquityProtectionPercentage = 90;
string gs_unused_296 = "";
bool gi_unused_304 = FALSE;
double gd_unused_308 = 3000.0;
string gs_unused_316 = "";
bool gi_unused_324 = FALSE;
int gi_unused_328 = 0;
int gi_unused_332 = 1;
string g_comment_336 = "";
extern string TradingTimeSettings;
extern bool UseTradingHours = FALSE;
bool gi_356 = FALSE;
int gi_360 = 11;
int gi_364 = 23;
bool gi_368 = FALSE;
int gi_372 = 7;
int gi_376 = 11;
bool gi_380 = TRUE;
extern int StartHour = 0;
extern int StopHour = 24;
bool gi_392 = TRUE;
string gs_unused_396 = "--Others Setting--";
int gi_unused_404 = 0;
string gs_unused_408 = "";
bool gi_416 = FALSE;
string gs_unused_420 = "";
bool gi_428 = FALSE;
int gi_432 = 0;
int g_color_436 = Black;
int gi_440 = 16;
bool gi_444 = TRUE;
int g_count_448 = 0;
int gi_unused_452 = 0;
int g_count_456 = 0;
int g_count_460 = 0;
int g_slippage_464 = 5;
double g_price_468 = 0.0;
double g_price_476 = 0.0;
double g_ask_484 = 0.0;
double g_bid_492 = 0.0;
double gd_500 = 0.0;
double g_lots_508 = 0.0;
int g_cmd_516 = OP_BUY;
int gi_520 = 0;
int gi_524 = 0;
double g_ord_open_price_528 = 0.0;
int gi_536 = 0;
double gd_unused_540 = 0.0;
int gi_unused_548 = 0;
int gi_unused_552 = 0;
double gd_unused_556 = 0.0;
double gd_unused_564 = 0.0;
double gd_unused_572 = 0.0;
double g_tickvalue_580 = 0.0;
bool gi_unused_588 = FALSE;
double gd_unused_592 = 0.0;
double gd_unused_600 = 0.0;
double gd_unused_608 = 0.0;
int gia_unused_616[][2];
bool gi_unused_620 = FALSE;
string gs_unused_624 = "5030.01.12 23:00";
int gi_unused_632 = 0;
int g_datetime_636 = 0;
bool gi_640;
int gi_unused_644 = 0;
double maxdd,maxpercentdd; 
int init() {
   int li_4;
   int l_digits_0 = MarketInfo(Symbol(), MODE_DIGITS);
   if (l_digits_0 == 2) li_4 = 1;
   if (l_digits_0 == 3) li_4 = 10;
   if (l_digits_0 == 4) li_4 = 1;
   if (l_digits_0 == 5) li_4 = 10;
   if (TakeProfit > 0) TakeProfit *= li_4;
   if (StopLoss > 0) StopLoss *= li_4;
   if (gi_192 > 0) gi_192 *= li_4;
   return (0);
}

int deinit() {
Print("MaxDD: ",maxdd);
Print("MaxPercDD: ",maxpercentdd);
   DeleteAllObjects();
   return (0);
}

int start() {
   bool l_bool_48;   
   double OpenProfit = AccountEquity()-AccountBalance();
   
   if (OpenProfit<maxdd){ maxdd = OpenProfit;}
   if ((OpenProfit/AccountBalance()*100)<maxpercentdd)
   { maxpercentdd = (OpenProfit/AccountBalance()*100);}
   
   if (ShowStatus){
   
   ObjectCreate( "B/E", OBJ_LABEL,0,0,0,0,0,0);
   ObjectSet(    "B/E", OBJPROP_CORNER,3);
   ObjectSet(    "B/E", OBJPROP_XDISTANCE, 3);
   ObjectSet(    "B/E", OBJPROP_YDISTANCE, 30);
   ObjectSetText("B/E", "B/E: $"+DoubleToStr(NormalizeDouble(AccountBalance(),2),1)+"/"+DoubleToStr(NormalizeDouble(AccountEquity(),2),1),24,"Impact",Red);
   
   ObjectCreate( "MaxDD", OBJ_LABEL,0,0,0,0,0,0);
   ObjectSet(    "MaxDD", OBJPROP_CORNER,3);
   ObjectSet(    "MaxDD", OBJPROP_XDISTANCE, 3);
   ObjectSet(    "MaxDD", OBJPROP_YDISTANCE, 2);
   ObjectSetText("MaxDD", "RDD Mï¿½x: $"+DoubleToStr(NormalizeDouble(maxdd,2),1)+"/"+DoubleToStr(NormalizeDouble(maxpercentdd,2),1)+"%",24,"Impact",Red);
   
   }
   
  if (GlobalVariableGet("GV_CloseAllAndHalt") > 0.0) return (0);
   string l_var_name_20 = AccountNumber() + "";
   if (!GlobalVariableCheck(l_var_name_20)) GlobalVariableSet(l_var_name_20, 0);
   double l_global_var_28 = GlobalVariableGet(l_var_name_20);
   double ld_36 = AccountMargin();
   if (l_global_var_28 < ld_36) {
      l_global_var_28 = ld_36;
      GlobalVariableSet(l_var_name_20, l_global_var_28);
   }
   int l_pos_44 = 0;
   string ls_52 = "";
   string ls_unused_60 = "";
   if (AccountType == 0) {
      if (gi_196 != 0) gd_500 = MathCeil(AccountBalance() * Risk / 10000.0);
      else gd_500 = Lots;
   }
   if (AccountType == 1) {
      if (gi_196 != 0) gd_500 = MathCeil(AccountBalance() * Risk / 10000.0) / 10.0;
      else gd_500 = Lots;
   }
   if (AccountType == 2) {
      if (gi_196 != 0) gd_500 = MathCeil(AccountBalance() * Risk / 10000.0) / 100.0;
      else gd_500 = Lots;
   }
   if (gd_500 < 0.01) gd_500 = 0.01;
   if (gd_500 > 100.0) gd_500 = 100;
   g_count_448 = 0;
   g_count_456 = 0;
   g_count_460 = 0;
   for (l_pos_44 = 0; l_pos_44 < OrdersTotal(); l_pos_44++) {
      if (OrderSelect(l_pos_44, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               g_count_456++;
               g_datetime_636 = OrderOpenTime();
            }
            if (OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYLIMIT) g_count_460++;
            g_count_448++;
         }
      }
   }
   
   if (g_count_448 < 1) {
      if (!gi_392 && DayOfWeek() == 5) {
         Comment("TradeOnfriday is False");
         return (0);
      }
   }
   g_tickvalue_580 = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (g_tickvalue_580 == 0.0) g_tickvalue_580 = 5;
   if (EquityProtection && AccountEquity() <= AccountBalance() * EquityProtectionPercentage / 100.0) {
      ls_52 = ls_52 
      + "\nEquity protection activated.";
      Print("Closing all orders");
      gi_536 = g_count_448 + 1;
      gi_444 = FALSE;
      return (0);
   }
   if (gi_536 > g_count_448) {
      for (l_pos_44 = OrdersTotal() - 1; l_pos_44 >= 0; l_pos_44--) {
         if (OrderSelect(l_pos_44, SELECT_BY_POS, MODE_TRADES)) {
            g_cmd_516 = OrderType();
            if ((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) || gi_268) {
               if (g_cmd_516 == OP_BUY || g_cmd_516 == OP_SELL) {
                  OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), g_slippage_464, g_color_436);
                  return (0);
               }
            }
         }
      }
      for (l_pos_44 = 0; l_pos_44 < OrdersTotal(); l_pos_44++) {
         if (OrderSelect(l_pos_44, SELECT_BY_POS, MODE_TRADES)) {
            g_cmd_516 = OrderType();
            if ((OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) || gi_268) {
               if (g_cmd_516 == OP_SELLLIMIT || g_cmd_516 == OP_BUYLIMIT || g_cmd_516 == OP_BUYSTOP || g_cmd_516 == OP_SELLSTOP) {
                  OrderDelete(OrderTicket());
                  return (0);
               }
            }
         }
      }
   }
   gi_536 = g_count_448;
   if (g_count_448 >= MaxTrades) gi_444 = FALSE;
   else gi_444 = TRUE;
   if (g_ord_open_price_528 == 0.0) {
      for (l_pos_44 = 0; l_pos_44 < OrdersTotal(); l_pos_44++) {
         if (OrderSelect(l_pos_44, SELECT_BY_POS, MODE_TRADES)) {
            g_cmd_516 = OrderType();
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               g_ord_open_price_528 = OrderOpenPrice();
               if (g_cmd_516 == OP_BUY) gi_520 = 2;
               if (g_cmd_516 == OP_SELL) gi_520 = 1;
            }
         }
      }
   }
   gi_524 = 3;
   int li_68 = gi_440;
   if (li_68 == 16) gi_524 = OpenOrdersBasedOnSTOCH();
   else gi_524 = OpenOrdersBasedOnSTOCH();
   if (g_count_448 < 1 && gi_432 == 0) {
      gi_520 = gi_524;
      if (gi_416) {
         if (gi_520 == 1) gi_520 = 2;
         else
            if (gi_520 == 2) gi_520 = 1;
      }
   }
   if (gi_416) {
      if (gi_524 == 1) gi_524 = 2;
      else
         if (gi_524 == 2) gi_524 = 1;
   }
   for (l_pos_44 = OrdersTotal() - 1; l_pos_44 >= 0; l_pos_44--) {
      if (OrderSelect(l_pos_44, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            if (gi_116 && gi_524 == 2) {
               gi_536 = g_count_448 + 1;
               gi_444 = FALSE;
               ls_52 = ls_52 + "";
               Print("");
            }
            if (gi_192 > 0) {
               if (OrderOpenPrice() - OrderClosePrice() >= gi_192 * Point + Pips * Point) {
                  if (OrderStopLoss() > OrderClosePrice() + gi_192 * Point) {
                     l_bool_48 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderClosePrice() + gi_192 * Point, OrderClosePrice() - TakeProfit * Point - gi_192 * Point, 0, Purple);
                     if (l_bool_48 != TRUE) Print("LastError = ", GetLastError());
                     else OrderPrint();
                     return (0);
                  }
               }
            }
         }
         if (OrderType() == OP_BUY) {
            if (gi_116 && gi_524 == 1) {
               gi_536 = g_count_448 + 1;
               gi_444 = FALSE;
               ls_52 = ls_52 + "";
               Print("");
            }
            if (gi_192 > 0) {
               if (OrderClosePrice() - OrderOpenPrice() >= gi_192 * Point + Pips * Point) {
                  if (OrderStopLoss() < OrderClosePrice() - gi_192 * Point) {
                     l_bool_48 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderClosePrice() - gi_192 * Point, OrderClosePrice() + TakeProfit * Point + gi_192 * Point, 0, g_color_436);
                     if (l_bool_48 != TRUE) Print("LastError = ", GetLastError());
                     else OrderPrint();
                     return (0);
                  }
               }
            }
         }
      }
   }
   
 
   
 
   if (UseTradingHours) {
      gi_640 = TRUE;
      if (gi_356) {
         if (gi_360 > 18) {
            if (Hour() >= gi_360) gi_640 = FALSE;
            if (!gi_640) {
               if (gi_364 < 24)
                  if (Hour() <= gi_364) gi_640 = FALSE;
               if (gi_364 >= 0)
                  if (Hour() <= gi_364) gi_640 = FALSE;
            }
         } else
            if (Hour() >= gi_360 && Hour() <= gi_364) gi_640 = FALSE;
      }
      if (gi_640) {
         if (gi_368)
            if (Hour() >= gi_372 && Hour() <= gi_376) gi_640 = FALSE;
      }
      if (gi_640) {
         if (gi_380)
            if (Hour() >= StartHour && Hour() <= StopHour) gi_640 = FALSE;
      }
      if (gi_640) return (0);
   }
   if (!IsTesting()) {
      if (gi_520 == 3 && g_count_448 < 1) {
         ls_52 = ls_52 
         + "\nOPEN ORDER";
      }
      Comment("Trading Active");
   }
   if (g_count_448 < 1) OpenMarketOrders();
   else {
      if (gi_428) OpenLimitOrders();
      else OpenMarketOrders();
   }
   return (0);
}

void OpenMarketOrders() {
   int l_count_0 = 0;
   if (gi_520 == 1 && gi_444) {
      if (Bid - g_ord_open_price_528 >= Pips * Point || g_count_448 < 1) {
         g_bid_492 = Bid;
         g_ord_open_price_528 = 0;
         if (TakeProfit == 0) g_price_476 = 0;
         else g_price_476 = g_bid_492 - TakeProfit * Point;
         if (StopLoss == 0) g_price_468 = 0;
         else g_price_468 = g_bid_492 + StopLoss * Point;
         if (g_count_448 != 0) {
            g_lots_508 = gd_500;
            for (l_count_0 = 0; l_count_0 < g_count_448; l_count_0++) {
               if (MaxTrades > 12) {
                  g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
                  continue;
               }
               g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
            }
         } else g_lots_508 = gd_500;
         if (g_lots_508 > 100.0) g_lots_508 = 100;
         OrderSend(Symbol(), OP_SELL, g_lots_508, NormalizeDouble(g_bid_492,Digits), g_slippage_464, g_price_468, g_price_476, g_comment_336, MagicNumber, 0, g_color_436);
         return;
      }
   }
   if (gi_520 == 2 && gi_444) {
      if (g_ord_open_price_528 - Ask >= Pips * Point || g_count_448 < 1) {
         g_ask_484 = Ask;
         g_ord_open_price_528 = 0;
         if (TakeProfit == 0) g_price_476 = 0;
         else g_price_476 = g_ask_484 + TakeProfit * Point;
         if (StopLoss == 0) g_price_468 = 0;
         else g_price_468 = g_ask_484 - StopLoss * Point;
         if (g_count_448 != 0) {
            g_lots_508 = gd_500;
            for (l_count_0 = 0; l_count_0 < g_count_448; l_count_0++) {
               if (MaxTrades > 12) {
                  g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
                  continue;
               }
               g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
            }
         } else g_lots_508 = gd_500;
         if (g_lots_508 > 100.0) g_lots_508 = 100;
         OrderSend(Symbol(), OP_BUY, g_lots_508, NormalizeDouble(g_ask_484,Digits), g_slippage_464, g_price_468, g_price_476, g_comment_336, MagicNumber, 0, g_color_436);
      }
   }
}

void OpenLimitOrders() {
   int l_count_0 = 0;
   if (gi_520 == 1 && gi_444) {
      g_bid_492 = g_ord_open_price_528 + Pips * Point;
      g_ord_open_price_528 = 0;
      if (TakeProfit == 0) g_price_476 = 0;
      else g_price_476 = g_bid_492 - TakeProfit * Point;
      if (StopLoss == 0) g_price_468 = 0;
      else g_price_468 = g_bid_492 + StopLoss * Point;
      if (g_count_448 != 0) {
         g_lots_508 = gd_500;
         for (l_count_0 = 0; l_count_0 < g_count_448; l_count_0++) {
            if (MaxTrades > 12) {
               g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
               continue;
            }
            g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
         }
      } else g_lots_508 = gd_500;
      if (g_lots_508 > 100.0) g_lots_508 = 100;
      OrderSend(Symbol(), OP_SELLLIMIT, g_lots_508, NormalizeDouble(g_bid_492,Digits), g_slippage_464, g_price_468, g_price_476, g_comment_336, MagicNumber, 0, g_color_436);
      return;
   }
   if (gi_520 == 2 && gi_444) {
      g_ask_484 = g_ord_open_price_528 - Pips * Point;
      g_ord_open_price_528 = 0;
      if (TakeProfit == 0) g_price_476 = 0;
      else g_price_476 = g_ask_484 + TakeProfit * Point;
      if (StopLoss == 0) g_price_468 = 0;
      else g_price_468 = g_ask_484 - StopLoss * Point;
      if (g_count_448 != 0) {
         g_lots_508 = gd_500;
         for (l_count_0 = 0; l_count_0 < g_count_448; l_count_0++) {
            if (MaxTrades > 12) {
               g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
               continue;
            }
            g_lots_508 = NormalizeDouble(g_lots_508 * Multi, 2);
         }
      } else g_lots_508 = gd_500;
      if (g_lots_508 > 100.0) g_lots_508 = 100;
      OrderSend(Symbol(), OP_BUYLIMIT, g_lots_508, NormalizeDouble(g_ask_484,Digits), g_slippage_464, g_price_468, g_price_476, g_comment_336, MagicNumber, 0, g_color_436);
   }
}

void DeleteAllObjects() {
   string l_name_4;
   int l_objs_total_0 = ObjectsTotal();
   for (int li_12 = 0; li_12 < l_objs_total_0; li_12++) {
      l_name_4 = ObjectName(li_12);
      if (l_name_4 != "") ObjectDelete(l_name_4);
   }
   ObjectDelete("FLP_txt");
   ObjectDelete("P_txt");
}

int OpenOrdersBasedOnSTOCH() {
   double ld_unused_4;
   double l_ma_method_16;
   int li_ret_0 = 3;
   switch (gi_108) {
   case 1:
      ld_unused_4 = 0;
      break;
   case 2:
      ld_unused_4 = 1;
      break;
   default:
      ld_unused_4 = 0;
   }
   switch (gi_112) {
   case 1:
      ld_unused_4 = 0;
      break;
   case 2:
      ld_unused_4 = 3;
      break;
   case 3:
      ld_unused_4 = 1;
      break;
   default:
      ld_unused_4 = 3;
   }
   double l_istochastic_28 = iStochastic(NULL, g_timeframe_88, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_MAIN, g_shift_96);
   double l_istochastic_36 = iStochastic(NULL, g_timeframe_88, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_MAIN, g_shift_96 + 3);
   double l_istochastic_44 = iStochastic(NULL, g_timeframe_92, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_MAIN, g_shift_96);
   double l_istochastic_52 = iStochastic(NULL, g_timeframe_92, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_MAIN, g_shift_96 + 3);
   double l_istochastic_60 = iStochastic(NULL, g_timeframe_88, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_SIGNAL, g_shift_96);
   double l_istochastic_68 = iStochastic(NULL, g_timeframe_88, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_SIGNAL, g_shift_96 + 3);
   double l_istochastic_76 = iStochastic(NULL, g_timeframe_92, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_SIGNAL, g_shift_96);
   double l_istochastic_84 = iStochastic(NULL, g_timeframe_92, g_period_76, g_period_80, g_slowing_84, l_ma_method_16, 0, MODE_SIGNAL, g_shift_96 + 3);
   double l_ienvelopes_92 = iEnvelopes(NULL, g_timeframe_124, g_period_120, MODE_SMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
   double l_ienvelopes_100 = iEnvelopes(NULL, g_timeframe_124, g_period_120, MODE_SMA, 0, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
   double l_ima_108 = iMA(NULL, g_timeframe_88, 2, 0, MODE_SMA, PRICE_CLOSE, 0);
   double l_ima_116 = iMA(NULL, g_timeframe_88, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
   if ((l_istochastic_28 < l_istochastic_60 && l_istochastic_36 >= l_istochastic_68 && l_istochastic_36 > gi_100 && (Low[0] > l_ienvelopes_100 && High[0] < l_ienvelopes_92)) ||
      (l_istochastic_44 < l_istochastic_76 && l_istochastic_52 >= l_istochastic_84 && l_istochastic_52 > gi_100 && l_ima_108 < l_ima_116 && Low[0] < l_ienvelopes_100 || High[0] > l_ienvelopes_92)) li_ret_0 = 1;
   if ((l_istochastic_28 > l_istochastic_60 && l_istochastic_36 <= l_istochastic_68 && l_istochastic_36 < gi_104 && (Low[0] > l_ienvelopes_100 && High[0] < l_ienvelopes_92)) ||
      (l_istochastic_44 > l_istochastic_76 && l_istochastic_52 <= l_istochastic_84 && l_istochastic_52 < gi_104 && l_ima_108 > l_ima_116 && Low[0] < l_ienvelopes_100 || High[0] > l_ienvelopes_92)) li_ret_0 = 2;
   return (li_ret_0);
}