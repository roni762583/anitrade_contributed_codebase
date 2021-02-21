/*
   Generated by EX4-TO-MQ4 decompiler V4.0.220.2c []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "www.eu4x.com"
#property link      "www.eu4x.com"

int gi_76 = 68932;
extern int YourAccountNumber = 12345;
bool gi_84 = FALSE;
int gi_88 = 5;
int gi_92 = 22;
int gi_96 = 2099;
extern int MagicNumber = 55555;
extern bool AlertOn = TRUE;
extern string soes = "---Special Order Management---";
extern bool SOE = FALSE;
extern string mm = "---Money Management---";
extern bool UseMoneyManagement = TRUE;
extern double TradeSizePercent = 1.0;
extern string mls = "--Manual Lot Size If MM = false--";
extern double Lots = 1.0;
extern bool BrokerIsIBFX = TRUE;
extern bool BrokerPermitsFractionalLots = TRUE;
extern string pom = "--Primary Order Management--";
extern int TakeProfit = 30;
extern int Slippage = 5;
extern string spf = "--Spread Filter---";
extern bool SpreadFilter = TRUE;
extern int SpreadLimit = 5;
extern string lom = "--Limit Order Management--";
extern double Multiplier = 2.0;
extern int TimeGrid = 60;
extern int Grid = 40;
extern int TP = 28;
extern double LotInc = 0.0;
extern int MaxLevel = 3;
extern string esl = "--Emergency Stop Loss--";
extern int StopLoss = 140;
extern string dnt = " --Delay Next Trade - 0 = false, 1 = true--";
extern int useDelayAfterClose = 1;
extern int MinutesToDelay = 15;
extern string tf = "--Trading Days / Hours Filter--";
extern int Broker_GMT_TimeShift = 3;
extern string ef3 = "Friday No Trade - 0 = false, 1 = true";
extern int UseFridayNoTrade = 1;
extern string es3 = "Sunday No Trade - 0 = false, 1 = true";
extern int UseSundayNoTrade = 1;
extern string sm0 = "--Trading Hours - Brokers GMT Server Time--";
extern string sm2 = "UseTradingHours - 0 = false, 1 = true";
extern int UseTradingHours = 1;
extern int TradeStart = 2005;
extern int TradeStop = 2230;
extern string ccs = "--Chart / EA Comments Settings---";
extern string CommentPrimaryOrders = "Primary Order";
extern int StatusTxtSize = 7;
extern color StatusColor = Gold;
extern int CommentTxtSize = 7;
extern color CommentColor = White;
int gi_360;
int gi_364;
int gi_368;
int gi_372;
int gi_376;
string gs_380;
string gs_388;
string gs_396;
string gs_404;
string gs_412;
string gs_420 = "Gedaliha";
int gi_428;
double g_lots_432;
double g_price_440;
double g_price_448;
int gi_456;
int gi_460;
bool gi_464 = FALSE;
bool gi_468 = FALSE;
double g_price_472;
double g_price_480;

int init() {
   gi_468 = TRUE;
   if (gi_468 == TRUE) {
      DeleteExistingLabels();
      SetupLabels();
      ClearLabels();
      if (gi_84 == FALSE) OutputStatusToChart(gs_420 + " Initialized");
      else OutputStatusToChart(gs_420 + " EA License Expires On " + gi_88 + "/" + gi_92 + "/" + gi_96);
   }
   watermark();
   return (0);
}

int deinit() {
   ClearLabels();
   DeleteExistingLabels();
   return (0);
}

int start() {
   double l_minlot_80;
   double l_ord_open_price_148;
   double l_ord_lots_156;
   double l_ord_takeprofit_164;
   double l_ord_stoploss_172;
   double l_ticket_180;
   double l_price_188;
   double l_lots_200;
   double l_irsi_4 = 0;
   double l_istochastic_12 = 0;
   double l_istochastic_20 = 0;
   double l_istochastic_28 = 0;
   double l_istochastic_36 = 0;
   bool li_44 = FALSE;
   double ld_unused_48 = 0;
   double ld_unused_56 = 0;
   double ld_unused_64 = 0;
   double ld_unused_72 = 0;
   int li_92 = Grid;
   int li_96 = TP;
   int li_100 = TakeProfit;
   int li_104 = StopLoss;
   int l_slippage_108 = Slippage;
   double ld_112 = (Ask - Bid) / Point;
   if (Digits == 3 || Digits == 5) {
      li_92 = 10 * Grid;
      li_96 = 10 * TP;
      li_100 = 10 * TakeProfit;
      li_104 = 10 * StopLoss;
      l_slippage_108 = 10 * Slippage;
      ld_112 /= 10.0;
   }
   if (SOE) {
      for (int l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderTakeProfit() == 0.0 && li_100 > 0) return (OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), g_price_480, 0));
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderStopLoss() == 0.0 && li_104 > 0) return (OrderModify(OrderTicket(), OrderOpenPrice(), g_price_472, OrderTakeProfit(), 0));
      }
   }
   int l_price_120 = !SpreadFilter || ld_112 <= SpreadLimit;
   if (gi_368 < 10) {
      SetupLabels();
      ClearLabels();
      DeleteExistingLabels();
      SetupLabels();
   }
   if (Bars < 100) {
      Print("Bars Less Than 100");
      OutputStatus2ToChart("Bars Less Than 100");
      return (0);
   }
   OutputStatus2ToChart("M5 Chart Only - Always Verify Broker GMT Time Shift Setting");
   if (IsTesting() == FALSE) {
      if (IsExpertEnabled() == FALSE) {
         OutputComment1ToChart("Expert Is Not Enabled");
         return (0);
      }
   }
   if (gi_468 == FALSE) return (0);
   g_lots_432 = GetLots();
   if (AccountCompany() != "Crown Forex SA") {
      if (BrokerIsIBFX) {
         if (AccountFreeMargin() < 100.0 * g_lots_432) {
            OutputComment1ToChart("Out Of Money Based On Trade Size Percent");
            return (0);
         }
      } else {
         if (AccountFreeMargin() < 1000.0 * g_lots_432) {
            OutputComment1ToChart("Out Of Money - Adjust Trade Risk Percent");
            return (0);
         }
      }
   }
   int l_count_124 = 0;
   int l_count_128 = 0;
   int l_count_132 = 0;
   int l_count_136 = 0;
   int l_count_140 = 0;
   int l_count_144 = 0;
   int li_196 = li_92;
   double ld_208 = li_96;
   for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
      OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUY) l_count_124++;
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELL) l_count_128++;
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUYLIMIT) l_count_132++;
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELLLIMIT) l_count_136++;
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUYSTOP) l_count_140++;
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_SELLSTOP) l_count_144++;
   }
   if (l_count_124 == 0 && l_count_128 == 0) {
      for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) OrderDelete(OrderTicket());
      }
   }
   if (l_count_124 > 0) {
      for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() != MagicNumber || OrderType() != OP_BUY || OrderSymbol() != Symbol()) continue;
         l_ord_open_price_148 = OrderOpenPrice();
         l_ord_lots_156 = OrderLots();
         l_ord_takeprofit_164 = OrderTakeProfit();
         l_ord_stoploss_172 = OrderStopLoss();
         l_ticket_180 = OrderOpenTime();
      }
      if (TimeCurrent() - TimeGrid > l_ticket_180 && l_count_124 < MaxLevel) {
         if (l_ord_open_price_148 > Ask) l_price_188 = NormalizeDouble(l_ord_open_price_148 - (MathRound((l_ord_open_price_148 - Ask) / Point / li_196) + 1.0) * li_196 * Point, Digits);
         else l_price_188 = NormalizeDouble(l_ord_open_price_148 - li_196 * Point, Digits);
         l_minlot_80 = MarketInfo(Symbol(), MODE_MINLOT);
         switch (l_minlot_80) {
         case 1.0:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 0);
            break;
         case 0.1:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 1);
            break;
         case 0.2:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 1);
            break;
         case 0.01:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 2);
            break;
         case 10000.0:
            l_lots_200 = 100000.0 * NormalizeDouble(l_ord_lots_156 / 100000.0 * Multiplier + LotInc, 1);
         }
         if (l_count_132 == 0) return (OrderSend(Symbol(), OP_BUYLIMIT, l_lots_200, l_price_188, 0, l_ord_stoploss_172, l_price_188 + ld_208 * Point, 0, MagicNumber));
      }
      for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() != MagicNumber || OrderType() != OP_BUY || MathAbs(OrderTakeProfit() - l_ord_takeprofit_164) < Point || OrderSymbol() != Symbol()) continue;
         OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_164, 0, Red);
         Print("m1");
         return;
      }
   }
   if (l_count_128 > 0) {
      for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() != MagicNumber || OrderType() != OP_SELL || OrderSymbol() != Symbol()) continue;
         l_ord_open_price_148 = OrderOpenPrice();
         l_ord_lots_156 = OrderLots();
         l_ord_takeprofit_164 = OrderTakeProfit();
         l_ord_stoploss_172 = OrderStopLoss();
         l_ticket_180 = OrderOpenTime();
      }
      if (TimeCurrent() - TimeGrid > l_ticket_180 && l_count_128 < MaxLevel) {
         if (Bid > l_ord_open_price_148) l_price_188 = NormalizeDouble(l_ord_open_price_148 + (MathRound(((-l_ord_open_price_148) + Bid) / Point / li_196) + 1.0) * li_196 * Point, Digits);
         else l_price_188 = NormalizeDouble(l_ord_open_price_148 + li_196 * Point, Digits);
         l_minlot_80 = MarketInfo(Symbol(), MODE_MINLOT);
         switch (l_minlot_80) {
         case 1.0:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 0);
            break;
         case 0.1:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 1);
            break;
         case 0.2:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 1);
            break;
         case 0.01:
            l_lots_200 = NormalizeDouble(l_ord_lots_156 * Multiplier + LotInc, 2);
            break;
         case 10000.0:
            l_lots_200 = 100000.0 * NormalizeDouble(l_ord_lots_156 / 100000.0 * Multiplier + LotInc, 1);
         }
         if (l_count_136 == 0) {
            OrderSend(Symbol(), OP_SELLLIMIT, l_lots_200, l_price_188, 0, l_ord_stoploss_172, l_price_188 - ld_208 * Point, 0, MagicNumber);
            Print("s4 " + l_lots_200);
            return;
         }
      }
      for (l_pos_88 = 0; l_pos_88 < OrdersTotal(); l_pos_88++) {
         OrderSelect(l_pos_88, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() != MagicNumber || OrderType() != OP_SELL || MathAbs(OrderTakeProfit() - l_ord_takeprofit_164) < Point || OrderSymbol() != Symbol()) continue;
         OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_164, 0, Red);
         Print("m2");
         return;
      }
   }
   gi_428 = CalculateCurrentOrders();
   if (gi_428 == 0) {
      if (useDelayAfterClose == 1) {
         gi_464 = LastTradeStoppedOut();
         if (TimeCurrent() < gi_460) {
            OutputComment3ToChart("Next Trade Delayed Until: " + TimeToStr(gi_460, TIME_DATE|TIME_MINUTES));
            return (0);
         }
         OutputComment3ToChart("Delay Before Next Trade Expired ");
      }
      gi_456 = CheckTradeFilters();
      if (gi_456 == 0) {
         l_irsi_4 = iRSI(Symbol(), 0, 9, PRICE_CLOSE, 1);
         l_istochastic_12 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
         l_istochastic_20 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
         l_istochastic_28 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
         l_istochastic_36 = iStochastic(Symbol(), 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
         if (l_irsi_4 >= 70.0 && l_istochastic_12 > 80.0 && l_istochastic_36 < l_istochastic_20 && l_istochastic_28 > l_istochastic_12) {
            li_44 = TRUE;
            for (int li_0 = 2; li_0 <= 1; li_0++) {
               if (iRSI(Symbol(), 0, 9, PRICE_CLOSE, li_0) < 70.0) {
                  li_44 = FALSE;
                  li_0 = 1;
               }
            }
            if (li_44 == TRUE && l_price_120) {
               Print("Sell Order Started  ", Bid);
               OutputComment2ToChart("Sell Order Started  " + Bid);
               g_price_448 = 0;
               if (li_100 > 0) g_price_448 = TakeShort(Bid, li_100);
               g_price_440 = 0;
               if (Digits > 0) {
                  g_price_440 = NormalizeDouble(g_price_440, Digits);
                  g_price_448 = NormalizeDouble(g_price_448, Digits);
               }
               if (li_104 > 0) {
                  if (!SOE) OrderSend(Symbol(), OP_SELL, g_lots_432, Bid, l_slippage_108, Bid + li_104 * Point, g_price_448, CommentPrimaryOrders, MagicNumber, 0, Red);
                  else {
                     g_price_472 = Bid + li_104 * Point;
                     g_price_480 = g_price_448;
                     OrderSend(Symbol(), OP_SELL, g_lots_432, Bid, l_slippage_108, 0, 0, CommentPrimaryOrders, MagicNumber, 0, Red);
                  }
               } else {
                  if (!SOE) OrderSend(Symbol(), OP_SELL, g_lots_432, Bid, l_slippage_108, g_price_440, g_price_448, CommentPrimaryOrders, MagicNumber, 0, Red);
                  else {
                     g_price_472 = g_price_440;
                     g_price_480 = g_price_448;
                     OrderSend(Symbol(), OP_SELL, g_lots_432, Bid, l_slippage_108, 0, 0, CommentPrimaryOrders, MagicNumber, 0, Red);
                  }
               }
               if (GetLastError() == 0/* NO_ERROR */) {
                  Print("Sell Order Opened : ", Bid);
                  if (AlertOn == TRUE) Alert("Sell Order Opened At " + Bid + " for " + Symbol());
                  OutputComment3ToChart("Sell Order Opened  " + Bid);
               }
            }
         }
         if (l_irsi_4 <= 30.0 && l_istochastic_12 < 20.0 && l_istochastic_36 > l_istochastic_20 && l_istochastic_28 < l_istochastic_12) {
            li_44 = TRUE;
            for (li_0 = 2; li_0 <= 1; li_0++) {
               if (iRSI(Symbol(), 0, 9, PRICE_CLOSE, li_0) > 30.0) {
                  li_44 = FALSE;
                  li_0 = 1;
               }
            }
            if (li_44 == TRUE && l_price_120) {
               Print("Buy Order Started  ", Ask);
               OutputComment2ToChart("Buy Order Started  " + Ask);
               g_price_448 = 0;
               if (li_100 > 0) g_price_448 = TakeLong(Ask, li_100);
               g_price_440 = 0;
               if (Digits > 0) {
                  g_price_440 = NormalizeDouble(g_price_440, Digits);
                  g_price_448 = NormalizeDouble(g_price_448, Digits);
               }
               if (li_104 > 0) {
                  if (!SOE) OrderSend(Symbol(), OP_BUY, g_lots_432, Ask, l_slippage_108, Ask - li_104 * Point, g_price_448, CommentPrimaryOrders, MagicNumber, 0, DodgerBlue);
                  else {
                     g_price_472 = Ask - li_104 * Point;
                     g_price_480 = g_price_448;
                     OrderSend(Symbol(), OP_BUY, g_lots_432, Ask, l_slippage_108, 0, 0, CommentPrimaryOrders, MagicNumber, 0, DodgerBlue);
                  }
               } else {
                  if (!SOE) OrderSend(Symbol(), OP_BUY, g_lots_432, Ask, l_slippage_108, g_price_440, g_price_448, CommentPrimaryOrders, MagicNumber, 0, DodgerBlue);
                  else {
                     g_price_472 = g_price_440;
                     g_price_480 = g_price_448;
                     OrderSend(Symbol(), OP_BUY, g_lots_432, Ask, l_slippage_108, 0, 0, CommentPrimaryOrders, MagicNumber, 0, DodgerBlue);
                  }
               }
               if (GetLastError() != 0/* NO_ERROR */) return;
               Print("Buy Order Opened : ", Ask);
               if (AlertOn == TRUE) Alert("Buy Order Opened At " + Ask + " for " + Symbol());
               OutputComment2ToChart("Buy Order Opened  " + Ask);
               return;
            }
         }
      }
   } else RefreshRates();
   return (0);
}

int LastTradeStoppedOut() {
   bool li_ret_8;
   int l_datetime_12;
   int l_hist_total_4 = OrdersHistoryTotal();
   for (int l_pos_0 = l_hist_total_4 - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() == Symbol()) {
         if (OrderMagicNumber() == MagicNumber) {
            l_datetime_12 = OrderCloseTime();
            if (TimeCurrent() - l_datetime_12 <= 60 * MinutesToDelay) {
               li_ret_8 = TRUE;
               l_pos_0 = 0;
            }
         }
      }
   }
   if (li_ret_8) gi_460 = l_datetime_12 + 60 * MinutesToDelay;
   return (li_ret_8);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
}

double GetLots() {
   double ld_ret_0;
   int li_ret_16;
   double l_maxlot_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   if (AccountCompany() == "Crown Forex SA" && UseMoneyManagement == FALSE) return (100000.0 * NormalizeDouble(Lots, 1));
   if (AccountCompany() == "Crown Forex SA") {
      li_ret_16 = 100000.0 * NormalizeDouble(AccountFreeMargin() * TradeSizePercent / 10000.0 / 10.0, 1);
      if (li_ret_16 < 10000) li_ret_16 = 10000;
      return (li_ret_16);
   }
   if (UseMoneyManagement == FALSE) return (Lots);
   if (BrokerIsIBFX == TRUE) {
      ld_ret_0 = Calc_IBFX_Money_Management();
      return (ld_ret_0);
   }
   double l_minlot_20 = MarketInfo(Symbol(), MODE_MINLOT);
   switch (l_minlot_20) {
   case 1.0:
      ld_ret_0 = NormalizeDouble(AccountFreeMargin() * TradeSizePercent / 10000.0 / 10.0, 0);
      if (ld_ret_0 < 1.0) ld_ret_0 = 1;
      break;
   case 0.1:
      ld_ret_0 = NormalizeDouble(AccountFreeMargin() * TradeSizePercent / 10000.0 / 10.0, 1);
      if (ld_ret_0 < 0.1) ld_ret_0 = 0.1;
      break;
   case 0.2:
      ld_ret_0 = NormalizeDouble(AccountFreeMargin() * TradeSizePercent / 10000.0 / 10.0, 1);
      if (ld_ret_0 < 0.2) ld_ret_0 = 0.2;
      break;
   case 0.01:
      ld_ret_0 = NormalizeDouble(AccountFreeMargin() * TradeSizePercent / 10000.0 / 10.0, 2);
      if (ld_ret_0 < 0.01) ld_ret_0 = 0.01;
   }
   if (BrokerPermitsFractionalLots == FALSE) {
      if (ld_ret_0 >= 1.0) ld_ret_0 = MathFloor(ld_ret_0);
      else ld_ret_0 = 1.0;
   }
   if (ld_ret_0 > l_maxlot_8) ld_ret_0 = l_maxlot_8;
   return (ld_ret_0);
}

double Calc_IBFX_Money_Management() {
   double l_minlot_0 = 0;
   double l_maxlot_8 = 0;
   double l_lotstep_16 = 0;
   double ld_24 = 0;
   int l_leverage_32 = 0;
   int l_lotsize_36 = 0;
   l_leverage_32 = AccountLeverage();
   l_minlot_0 = MarketInfo(Symbol(), MODE_MINLOT);
   l_maxlot_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   l_lotstep_16 = MarketInfo(Symbol(), MODE_LOTSTEP);
   l_lotsize_36 = MarketInfo(Symbol(), MODE_LOTSIZE);
   if (l_lotstep_16 == 0.01) ld_24 = 2;
   if (l_lotstep_16 == 0.1) ld_24 = 1;
   double ld_ret_40 = AccountFreeMargin() * (TradeSizePercent / 100.0) / (l_lotsize_36 / l_leverage_32);
   if (BrokerPermitsFractionalLots == TRUE) ld_ret_40 = StrToDouble(DoubleToStr(ld_ret_40, ld_24));
   else ld_ret_40 = MathRound(ld_ret_40);
   if (ld_ret_40 < l_minlot_0) ld_ret_40 = l_minlot_0;
   if (ld_ret_40 > l_maxlot_8) ld_ret_40 = l_maxlot_8;
   return (ld_ret_40);
}

int CheckTradeFilters() {
   bool li_4;
   int li_12;
   int li_ret_0 = 0;
   if (gi_84 == TRUE) {
      li_4 = FALSE;
      if (Year() > gi_96) li_4 = TRUE;
      if (li_4 == FALSE) {
         if (Year() == gi_96 && Month() > gi_88) li_4 = TRUE;
         if (li_4 == FALSE)
            if (Year() == gi_96 && Month() == gi_88 && Day() > gi_92) li_4 = TRUE;
      }
      if (li_4 == TRUE) OutputComment1ToChart("EA License Has Expired - Renew At www.eu4x.com");
      li_ret_0 = li_4;
   }
   int li_8 = DayOfWeek();
   if (Hour() - Broker_GMT_TimeShift < 0) li_8--;
   if (Hour() - Broker_GMT_TimeShift >= 24) li_8++;
   if (li_ret_0 == 0) {
      if (UseFridayNoTrade == 1) {
         if (li_8 == 5) {
            li_ret_0 = 1;
            OutputComment1ToChart("Trading Not Authorized On Friday");
         }
      }
   }
   if (li_ret_0 == 0) {
      if (UseSundayNoTrade == 1) {
         li_12 = Hour() - Broker_GMT_TimeShift;
         if (li_12 < 0) li_12 += 24;
         if (li_12 >= 24) li_12 -= 24;
         li_12 = 100 * li_12 + Minute();
         if (li_8 == 0 || (li_8 == 1 && li_12 < TradeStart)) {
            li_ret_0 = 1;
            OutputComment1ToChart("Current Trading Hours Are Not Authorized");
         }
      }
   }
   if (li_ret_0 == 0) {
      if (UseTradingHours == 1) {
         li_ret_0 = CheckTradingTimes();
         if (li_ret_0 == 1) OutputComment1ToChart("Current Trading Hours Are Not Authorized");
         else OutputComment1ToChart("Current Trading Hours Are Authorized");
      } else OutputComment1ToChart("Trading Hours Filter Is Not Enabled");
   }
   return (li_ret_0);
}

int IsNotValidTradingTime(int ai_0, int ai_4) {
   int li_8 = Hour() - Broker_GMT_TimeShift;
   if (li_8 < 0) li_8 += 24;
   if (li_8 >= 24) li_8 -= 24;
   li_8 = 100 * li_8 + Minute();
   if (ai_0 <= ai_4) {
      if (li_8 < ai_0 || li_8 > ai_4) return (1);
   } else
      if (li_8 > ai_4 && li_8 < ai_0) return (1);
   return (0);
}

int CheckTradingTimes() {
   int li_0 = 1;
   li_0 = IsNotValidTradingTime(TradeStart, TradeStop);
   return (li_0);
}

int CalculateCurrentOrders() {
   int l_count_0 = 0;
   int l_count_4 = 0;
   int li_ret_8 = 0;
   for (int l_pos_12 = 0; l_pos_12 < OrdersTotal(); l_pos_12++) {
      OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) l_count_0++;
            if (OrderType() == OP_SELL) l_count_4++;
         }
      }
   }
   li_ret_8 = l_count_0 + l_count_4;
   return (li_ret_8);
}

void ClearLabels() {
   string ls_0 = " ";
   OutputLabelToChart(gs_380, gi_360, StatusTxtSize, StatusColor, ls_0);
   OutputLabelToChart(gs_388, gi_364, StatusTxtSize, StatusColor, ls_0);
   OutputLabelToChart(gs_396, gi_368, CommentTxtSize, CommentColor, ls_0);
   OutputLabelToChart(gs_404, gi_372, CommentTxtSize, CommentColor, ls_0);
   OutputLabelToChart(gs_412, gi_376, CommentTxtSize, CommentColor, ls_0);
}

void DeleteExistingLabels() {
   string l_name_4;
   int l_objs_total_0 = ObjectsTotal(OBJ_LABEL);
   if (l_objs_total_0 > 0) {
      for (int l_objs_total_12 = l_objs_total_0; l_objs_total_12 >= 0; l_objs_total_12--) {
         l_name_4 = ObjectName(l_objs_total_12);
         if (StringFind(l_name_4, Symbol() + "Status", 0) >= 0) ObjectDelete(l_name_4);
         else {
            if (StringFind(l_name_4, Symbol() + "Comment1", 0) >= 0) ObjectDelete(l_name_4);
            else {
               if (StringFind(l_name_4, Symbol() + "Comment2", 0) >= 0) ObjectDelete(l_name_4);
               else
                  if (StringFind(l_name_4, Symbol() + "Comment3", 0) >= 0) ObjectDelete(l_name_4);
            }
         }
      }
   }
}

void SetupLabels() {
   gi_360 = 12;
   gi_364 = gi_360 + StatusTxtSize + 4;
   gi_368 = gi_364 + StatusTxtSize + 4;
   gi_372 = gi_368 + CommentTxtSize + 4;
   gi_376 = gi_372 + CommentTxtSize + 4;
   gs_380 = Symbol() + "Status";
   gs_388 = Symbol() + "Status2";
   gs_396 = Symbol() + "Comment1";
   gs_404 = Symbol() + "Comment2";
   gs_412 = Symbol() + "Comment3";
}

void OutputLabelToChart(string a_name_0, int a_y_8, int a_fontsize_12, color a_color_16, string a_text_20) {
   if (ObjectFind(a_name_0) != 0) {
      ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(a_name_0, OBJPROP_CORNER, 0);
      ObjectSet(a_name_0, OBJPROP_XDISTANCE, 20);
      ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_8);
   }
   ObjectSetText(a_name_0, a_text_20, a_fontsize_12, "Arial Bold", a_color_16);
}

void OutputStatusToChart(string as_0) {
   OutputLabelToChart(gs_380, gi_360, StatusTxtSize, StatusColor, as_0);
}

void OutputStatus2ToChart(string as_0) {
   OutputLabelToChart(gs_388, gi_364, StatusTxtSize, StatusColor, as_0);
}

void OutputComment1ToChart(string as_0) {
   OutputLabelToChart(gs_396, gi_368, CommentTxtSize, CommentColor, as_0);
}

void OutputComment2ToChart(string as_0) {
   OutputLabelToChart(gs_404, gi_372, CommentTxtSize, CommentColor, as_0);
}

void OutputComment3ToChart(string as_0) {
   OutputLabelToChart(gs_412, gi_376, CommentTxtSize, CommentColor, as_0);
}

void watermark() {
   ObjectCreate("eu4x.com", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("eu4x.com", "Gedaliha", 9, "Arial", DeepSkyBlue);
   ObjectSet("eu4x.com", OBJPROP_CORNER, 2);
   ObjectSet("eu4x.com", OBJPROP_XDISTANCE, 5);
   ObjectSet("eu4x.com", OBJPROP_YDISTANCE, 10);
}