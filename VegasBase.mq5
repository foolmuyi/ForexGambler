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
const string symbol = "XAUUSD";
const ENUM_TIMEFRAMES timeframe = PERIOD_M5;
const double lot = 0.1;
const int magic_num = 2333;
const uint fast_period = 144;  // 短周期
const uint slow_period = 169;  // 长周期
const uint filter_period = 12;  // 过滤线周期


// Useful global variables
double OnePoint;
int digits;
double ma_fast[];
double ma_slow[];
double ma_filter[];
int sl_flag = 0;


CTrade m_trade;
CDealInfo m_DealInfo;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- create timer
  EventSetTimer(1);

  OnePoint = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
  digits = SymbolInfoInteger(symbol, SYMBOL_DIGITS);

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

    bool ma_fast_res = FetchData(ma_fast, fast_period);
    ArrayReverse(ma_fast);
    bool ma_slow_res = FetchData(ma_slow, slow_period);
    ArrayReverse(ma_slow);
    bool ma_filter_res = FetchData(ma_filter, filter_period);
    ArrayReverse(ma_filter);

    // buy conditions
    bool buy_cond_1 = PositionsTotal() == 0;
    bool buy_cond_2 = (ma_slow[1] < ma_fast[1]) && (ma_fast[1] < ma_filter[1]);

    if(buy_cond_1 && buy_cond_2)
     {
      MyBuy(NormalizeDouble(ma_fast[1], digits));
      double dis = ma_filter[1] - ma_slow[1];
      double sl = NormalizeDouble(ma_slow[1] - dis, digits);
      ModSLTP(sl);
      sl_flag = 1;
     }

    // move sl conditions
    bool sell_cond_1 = ((ma_filter[1] > ma_filter[2]) && (ma_filter[2] > ma_filter[3]));
    bool sell_cond_2 = ((ma_filter[1] - ma_fast[1]) >= 2*(ma_fast[1] - ma_slow[1]));
    bool sell_cond_3 = ((ma_filter[1] - ma_fast[1]) >= 4*(ma_fast[1] - ma_slow[1]));


    if((sl_flag==1) && (ma_fast[1] <= ma_slow[1]))
     {
      CloseAllPositions();
     }

    if((sl_flag==1) && sell_cond_1 && sell_cond_2)
     {
      ModSLTP(NormalizeDouble(ma_slow[1], digits));
      sl_flag = 2;
     }

    if((sl_flag==2) && sell_cond_3)
     {
      ModSLTP(NormalizeDouble(ma_fast[1], digits));
      sl_flag = 3;
     }

    if(sl_flag==3)
     {
      ModSLTP(NormalizeDouble(ma_fast[1], digits));
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
  datetime currentOpenTime = iTime(symbol, timeframe, 0);
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
void MyBuy(double price)
 {

  m_trade.BuyLimit(lot, price, symbol);

 }


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
//    m_trade.PositionModify(ticket, 0, tp);
//   }
//  else
//   {
//    m_trade.PositionModify(ticket, tp, 0);
//   }
//
//  uint res = m_trade.ResultRetcode();
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
  m_trade.PositionModify(ticket, tp, 0);

  uint res = m_trade.ResultRetcode();
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
    m_trade.OrderDelete(ticket);

    uint res = m_trade.ResultRetcode();
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
  int ma_handle = iMA(symbol, timeframe, ma_period, 0, MODE_EMA, PRICE_CLOSE);
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
    m_trade.PositionClose(ticket);

    uint res = m_trade.ResultRetcode();
    if(!res)
     {
      Print(GetLastError());
      Print(res);
     }
   }
 }
//+------------------------------------------------------------------+
