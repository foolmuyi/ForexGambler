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


const string g_symbol = "EURUSD";
const ENUM_TIMEFRAMES period = PERIOD_M5;
const double lot = 0.1;
double OnePoint;


CTrade g_trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   OnePoint = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);

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
      CancelAllOrders();
      //CloseAllPositions();
      BuyBuy();
     }

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyBuy()
  {
   double buyPrice = iClose(g_symbol, period, 1) - OnePoint*20;
   double sl = buyPrice - OnePoint*1000;
   double tp = buyPrice + OnePoint*40;
   datetime expiration_time = datetime(uint(iTime(g_symbol, period, 0))+PeriodSeconds(period));

   if(PositionsTotal() == 0)
     {
      g_trade.BuyLimit(lot, buyPrice, g_symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration_time);
     }
   else
      if(PositionsTotal() < 3)
        {
         g_trade.BuyLimit(lot, buyPrice, g_symbol, sl, 0.0, ORDER_TIME_SPECIFIED, expiration_time);
         ModTP(tp);
        }
      else
        {
         ModTP(tp);
        }

//bool res = OrderSend(request, result);
//if(!res)
//  Print(GetLastError());
//Print(result.retcode);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
// 获取当前K线的Open时间
   datetime currentOpenTime = iTime(g_symbol, period, 0);
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
//|                                                                  |
//+------------------------------------------------------------------+
void ModTP(double tp)
  {
   ulong ticket = PositionGetTicket(0);
   PositionSelectByTicket(ticket);
   double sl = PositionGetDouble(POSITION_SL);
   g_trade.PositionModify(ticket, sl, tp);

   uint res = g_trade.ResultRetcode();
   if(!res)
     {
      Print(GetLastError());
      Print(res);
     }
  }
//+------------------------------------------------------------------+
