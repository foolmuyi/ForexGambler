//+------------------------------------------------------------------+
//|                                                    VegasBase.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>


// configs
const string g_symbol = "USDJPY";
const ENUM_TIMEFRAMES g_timeframe = PERIOD_M30;
double g_lot = 0.1;
const int g_magic_num = 2333;
const uint g_fast_period = 144;  // 短周期
const uint g_slow_period = 169;  // 长周期
const uint g_filter_period = 12;  // 过滤线周期
const uint g_long_fast_period = 576;
const uint g_long_slow_period = 676;


// Useful global variables
double g_OnePoint;
int g_digits;
double g_ma_fast[];
double g_ma_slow[];
double g_ma_filter[];
double g_ma_long_fast[];
double g_ma_long_slow[];
int g_sl_flag = 0;


CTrade g_trade;
CDealInfo g_DealInfo;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- create timer
  EventSetTimer(1);

  g_OnePoint = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
  g_digits = SymbolInfoInteger(g_symbol, SYMBOL_DIGITS);

//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//--- destroy timer
  EventKillTimer();

 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
//---

 }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
 {
  if(IsNewCandle())
   {
    if(OrdersTotal() > 0)
     {
      CancelAllOrders();
     }

    bool ma_fast_res = FetchData(g_ma_fast, g_fast_period);
    ArrayReverse(g_ma_fast);
    bool ma_slow_res = FetchData(g_ma_slow, g_slow_period);
    ArrayReverse(g_ma_slow);
    bool ma_filter_res = FetchData(g_ma_filter, g_filter_period);
    ArrayReverse(g_ma_filter);
    bool ma_long_fast_res = FetchData(g_ma_long_fast, g_long_fast_period);
    ArrayReverse(g_ma_long_fast);
    bool ma_long_slow_res = FetchData(g_ma_long_slow, g_long_slow_period);
    ArrayReverse(g_ma_long_slow);

    // buy conditions
    bool buy_cond_1 = PositionsTotal() == 0;
    bool buy_cond_2 = (g_ma_slow[1] < g_ma_fast[1]);
    bool buy_cond_3 = (g_ma_fast[1] < g_ma_filter[1]);
    bool buy_cond_4 = (g_ma_long_fast[1] < g_ma_slow[1]) && (g_ma_long_slow[1] < g_ma_long_fast[1]);
    bool buy_cond_5_1 = (iLow(g_symbol, g_timeframe, 2) < g_ma_fast[2]) && (iLow(g_symbol, g_timeframe, 1) > g_ma_fast[1]);
    bool buy_cond_5_2 = (iLow(g_symbol, g_timeframe, 2) < g_ma_long_fast[2]) && (iLow(g_symbol, g_timeframe, 1) > g_ma_long_fast[1]);

    if(buy_cond_1)
     {
      g_sl_flag = 0;
      
      // 全仓买入
      //double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      //g_lot = double(int(balance/100))/10;
      
      if(buy_cond_2 && buy_cond_3 && buy_cond_4)
       {
        double sl = NormalizeDouble(g_ma_long_fast[1], g_digits);
        double price = NormalizeDouble(g_ma_slow[1], g_digits);
        g_trade.BuyLimit(g_lot, price, g_symbol, sl);
        g_sl_flag = 1;
        return;  // 刚买，不检查平仓和移动止损条件
       }
     }

    //    if(buy_cond_1)
    //     {
    //      g_sl_flag = 0;
    //
    //      if(buy_cond_2 && buy_cond_3 && buy_cond_4 && buy_cond_5_1)
    //       {
    //        double sl = NormalizeDouble(g_ma_slow[1], g_digits);
    //        g_trade.Buy(g_lot, g_symbol, 0.0, sl);
    //        g_sl_flag = 1;
    //       }
    //
    //      if(buy_cond_2 && buy_cond_4 && buy_cond_5_2)
    //       {
    //        double sl = NormalizeDouble(g_ma_long_slow[1], g_digits);
    //        g_trade.Buy(g_lot, g_symbol, 0.0, sl);
    //        g_sl_flag = 1;
    //       }
    //     }
    
    bool close_cond_1 = g_ma_fast[1] <= g_ma_slow[1];
    bool close_cond_2 = iHigh(g_symbol, g_timeframe, 1) < g_ma_slow[1];
    
    if((!buy_cond_1) && (close_cond_1 || close_cond_2))
     {
      CloseAllPositions();
      g_sl_flag = 0;
     }
     
    // move sl conditions
    //bool sl_cond_1 = ((g_ma_filter[1] > g_ma_filter[2]) && (g_ma_filter[2] > g_ma_filter[3]));
    //bool sl_cond_2 = ((g_ma_filter[1] - g_ma_fast[1]) >= 2*(g_ma_fast[1] - g_ma_slow[1]));
    //bool sl_cond_3 = ((g_ma_filter[1] - g_ma_fast[1]) >= 4*(g_ma_fast[1] - g_ma_slow[1]));
    bool sl_cond_4 = iLow(g_symbol, g_timeframe, 1) > g_ma_fast[1];

    //if((g_sl_flag==1) && sl_cond_1 && sl_cond_2)
    // {
    //  ModSLTP(NormalizeDouble(g_ma_long_fast[1], g_digits));
    //  g_sl_flag = 2;
    // }

    //    if((g_sl_flag==2) && sl_cond_3)
    //     {
    //      ModSLTP(NormalizeDouble(g_ma_slow[1]+g_ma_slow[1]-g_ma_fast[1], g_digits));
    //      g_sl_flag = 3;
    //     }
    //

    if((g_sl_flag==1) && sl_cond_4)
     {
      ModSLTP(NormalizeDouble(g_ma_slow[1], g_digits));
      g_sl_flag = 3;
     }

    if(g_sl_flag==3)
     {
      ModSLTP(NormalizeDouble(g_ma_slow[1], g_digits));
     }

   }
 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
 {
// 获取当前K线的Open时间
  datetime currentOpenTime = iTime(g_symbol, g_timeframe, 0);
  uint currentOpenSeconds = uint(currentOpenTime);

// 获取当前时间
  datetime currentTime = TimeGMT();
  uint currentSeconds = uint(currentTime);

// 如果当前时间等于当前k线的Open时间，则新的K线产生
  if(currentSeconds == currentOpenSeconds)
    return true;
  else
    return false;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void ModSLTP(double tp)
// {
//  ulong ticket = PositionGetTicket(0);
//  PositionSelectByTicket(ticket);
//  double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
//  if(tp >= open_price)
//   {
//    g_trade.PositionModify(ticket, 0, tp);
//   }
//  else
//   {
//    g_trade.PositionModify(ticket, tp, 0);
//   }
//
//  uint res = g_trade.ResultRetcode();
//  if(!res)
//   {
//    Print(GetLastError());
//    Print(res);
//   }
// }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModSLTP(double tp)
 {
  ulong ticket = PositionGetTicket(0);
  PositionSelectByTicket(ticket);;
  g_trade.PositionModify(ticket, tp, 0);

  uint res = g_trade.ResultRetcode();
  if(!res)
   {
    Print(GetLastError());
    Print(res);
   }
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelAllOrders()
 {
  int order_num = OrdersTotal();
  for(int i=0; i<order_num; i++)
   {
    ulong ticket = OrderGetTicket(i);
    g_trade.OrderDelete(ticket);

    uint res = g_trade.ResultRetcode();
    if(!res)
     {
      Print(GetLastError());
      Print(res);
     }

   }
 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FetchData(double &buffer[], int ma_period)
 {
  int ma_handle = iMA(g_symbol, g_timeframe, ma_period, 0, MODE_EMA, PRICE_CLOSE);
  int res = CopyBuffer(ma_handle, 0, 0, 20, buffer);

  if((ma_handle == INVALID_HANDLE) || (res == -1))
    return false;
  else
    return true;
 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
 {
  for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
    ulong ticket = PositionGetTicket(i);
    g_trade.PositionClose(ticket);

    uint res = g_trade.ResultRetcode();
    if(!res)
     {
      Print(GetLastError());
      Print(res);
     }
   }
 }
//+------------------------------------------------------------------+
