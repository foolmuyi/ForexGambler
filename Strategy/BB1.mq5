//+------------------------------------------------------------------+
//|                                               checkNewCandle.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>


// configs
const int magic_num = 2333;
const string symbol = "USDCAD";
const ENUM_TIMEFRAMES timeframe = PERIOD_M5;
const double lot = 0.01;
const uint fast_period = 80;  // 短周期
const uint slow_period = 200;  // 长周期
const ulong time_interval = 900;  // 三根k线

// Useful global variables
double OnePoint;
double ma_fast[];
double ma_slow[];
double BB_up[];
double BB_low[];

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

    int BB_handle = iBands(symbol, timeframe, 20, 0, 2, PRICE_CLOSE);
    CopyBuffer(BB_handle, 1, 0, 2, BB_up);
    CopyBuffer(BB_handle, 2, 0, 2, BB_low);

    double ma_fast[];
    double ma_slow[];
    int ma_fast_handle = iMA(symbol, timeframe, fast_period, 0, MODE_EMA, PRICE_CLOSE);
    CopyBuffer(ma_fast_handle, 0, 1, 2, ma_fast);
    int ma_slow_handle = iMA(symbol, timeframe, slow_period, 0, MODE_EMA, PRICE_CLOSE);
    CopyBuffer(ma_slow_handle, 0, 1, 2, ma_slow);

    if((BB_low[0] <= 0) || BB_up[0] <= 0)
      return;

    if(ma_fast[0] <= ma_slow[0])
     {
      if(PositionsTotal() > 0)
       {
        CloseAllPositions();
        return;
       }
     }
    else
     {
      double close_price = iClose(symbol, timeframe, 1);

      if((close_price > BB_up[0]) && CheckLastBuyTime(time_interval))
       {
        m_trade.BuyLimit(lot, BB_low[0], symbol);
       }
      else
        if((close_price > BB_low[0]) && (close_price < BB_up[0]))
         {
          if(CheckLastBuyTime(time_interval))
           {
            m_trade.BuyLimit(lot, BB_low[0], symbol);
           }
          if(PositionsTotal() > 0)
           {
            ModSLTP(BB_up[0]);
           }
         }
        else
          if((close_price < BB_low[0]) && (PositionsTotal() > 0))
           {
            ModSLTP(BB_up[0]);
           }
          else
            return;
     }
   }
  else
    return;
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
//|                                                                  |
//+------------------------------------------------------------------+
void ModSLTP(double tp)
 {
  ulong ticket = PositionGetTicket(0);
  PositionSelectByTicket(ticket);
  double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
  if(tp >= open_price)
   {
    m_trade.PositionModify(ticket, 0, tp);
   }
  else
   {
    m_trade.PositionModify(ticket, tp, 0);
   }

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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckLastBuyTime(ulong time_interval)
 {
  HistorySelect(0,TimeCurrent());
  for(uint i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
    m_DealInfo.SelectByIndex(i);
    ENUM_DEAL_ENTRY dealEntry = m_DealInfo.Entry();
    if(dealEntry == 0)
     {
      ulong time_len = (ulong(TimeCurrent())*1000 - m_DealInfo.TimeMsc())/1000;
      Print(time_len);
      if(time_len >= time_interval)
       {
        return true;
       }
      else
       {
        return false;
       }
     }
   }
  return false;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
