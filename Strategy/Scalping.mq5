//+------------------------------------------------------------------+
//|                                               checkNewCandle.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"



const string symbol = "EURUSD";
const ENUM_TIMEFRAMES period = PERIOD_M1;
const double lot = 0.01;
double OnePoint;

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
         //BuyBuy();
         TryTrade();
      }
   
  }
//+------------------------------------------------------------------+


void TryTrade()
   {
      if (CheckValley() && CheckBullEngulf() && (OrdersTotal() == 0))
         {
            BuyBuy();
         }
   }


bool IsNewCandle()
  {
    // 获取当前K线的Open时间
    datetime currentOpenTime = iTime(symbol, period, 0);
    uint currentOpenSeconds = uint(currentOpenTime);
    
    // 获取当前时间
    datetime currentTime = TimeGMT();
    uint currentSeconds = uint(currentTime);

    // 如果当前时间等于当前k线的Open时间，则新的K线产生
    if (currentSeconds == currentOpenSeconds)
      return true;
    else
      return false;
  }
   
   
bool CheckValley()
   {
      double firstBarLow = MathMin(iOpen(symbol, period, 2), iClose(symbol, period, 2));
      double secondBarLow = MathMin(iOpen(symbol, period, 3), iClose(symbol, period, 3));
      double thirdBarLow = MathMin(iOpen(symbol, period, 4), iClose(symbol, period, 4));
      
      double firstBarHigh = MathMax(iOpen(symbol, period, 2), iClose(symbol, period, 2));
      double secondBarHigh = MathMax(iOpen(symbol, period, 3), iClose(symbol, period, 3));
      double thirdBarHigh = MathMax(iOpen(symbol, period, 4), iClose(symbol, period, 4));
      if ((firstBarLow < secondBarLow) && (secondBarLow < thirdBarLow) && (firstBarHigh < secondBarHigh) && (secondBarHigh < thirdBarHigh))
         return true;
      else
         return false;
   }


bool CheckBullEngulf()
   {
      bool cond_1 = (iOpen(symbol, period, 2) > iClose(symbol, period, 2));    // 阴线
      bool cond_2 = (iOpen(symbol, period, 1) <= iClose(symbol, period, 2));
      bool cond_3 = (iClose(symbol, period, 1) >= iOpen(symbol, period, 2));    // 吞没形态
      
      if (cond_1 && cond_2 && cond_3)
         return true;
      else
         return false;
   }
   
void BuyBuy()
   {
      double buyPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double sl = buyPrice - OnePoint*50;
      double tp = buyPrice + OnePoint*100;
      
      MqlTradeRequest request;
      ZeroMemory(request);
      MqlTradeResult result;
      
      request.action = TRADE_ACTION_DEAL;
      request.magic = 2333;
      request.symbol = symbol;
      request.volume = lot;
      request.price = buyPrice;
      request.sl = sl;
      request.tp = tp;
      request.deviation = 5;
      request.type = ORDER_TYPE_BUY;
      request.type_filling = ORDER_FILLING_FOK;
      request.type_time = ORDER_TIME_GTC;
      
      bool res = OrderSend(request, result);
      if (!res)
         Print(GetLastError());
         Print(result.retcode);
   }