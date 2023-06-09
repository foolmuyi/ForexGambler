//+------------------------------------------------------------------+
//|                                               checkNewCandle.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"


bool IsNewCandle(string symbol, ENUM_TIMEFRAMES period)
  {
    // 获取当前K线的Open时间
    datetime currentOpenTime = iTime(symbol, period, 0);
    uint currentOpenSeconds = uint(currentOpenTime);
    
    // 获取当前时间
    datetime currentTime = TimeCurrent();
    uint currentSeconds = uint(currentTime);

    // 如果当前时间等于当前k线的Open时间，则新的K线产生
    if (currentSeconds == currentOpenSeconds)
      return true;
    else
      return false;

  }





//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
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
   if(IsNewCandle(_Symbol, PERIOD_M1))
      Print("New candle!");
   
  }
//+------------------------------------------------------------------+
