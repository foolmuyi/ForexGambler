//+------------------------------------------------------------------+
//|                                                     Scalping.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  
bool isNewCandle(string symbol, ENUM_TIMEFRAMES period)
   {
       // 获取当前K线的Open时间
       datetime currentOpenTime = iTime(symbol, period, 0);
       uint currentOpenSeconds = uint(currentOpenTime);
   
       // 获取上一个K线的Open时间
       datetime previousOpenTime = iTime(symbol, period, 1);
       uint previousOpenSeconds = uint(previousOpenTime);
       
       // 获取当前时间
       datetime currentTime = TimeCurrent();
       int currentSeconds = uint(currentTime);
   
       // 如果当前时间等于当前Open时间且当前Open时间大于上一个Open时间，则新的K线产生
       if (currentSeconds == currentOpenSeconds && currentOpenSeconds > previousOpenSeconds)
         return true;
       else
         return false;
   }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    Print("Chekcing...");
    if(isNewCandle(_Symbol, PERIOD_M1))
    {
      Print("New candle generated!");
    }
   
  }
//+------------------------------------------------------------------+
