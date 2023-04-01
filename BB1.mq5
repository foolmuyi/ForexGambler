//+------------------------------------------------------------------+
//|                                               checkNewCandle.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"



const string symbol = "XAUUSD";
const ENUM_TIMEFRAMES period = PERIOD_M5;
const double lot = 0.01;
const uint fast_period = 144;  // 短周期
const uint slow_period = 169;  // 长周期

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
    if(OrdersTotal() > 0)
     {
      CancelAllOrders();
     }
    double BB_up[];
    double BB_low[];
    int BB_handle = iBands(symbol, period, 20, 0, 1, PRICE_CLOSE);
    CopyBuffer(BB_handle, 1, 0, 2, BB_up);
    CopyBuffer(BB_handle, 2, 0, 2, BB_low);
    
    double ma_fast[];
    double ma_slow[];
    int ma_fast_handle = iMA(symbol, period, fast_period, 0, MODE_EMA, PRICE_CLOSE);
    CopyBuffer(ma_fast_handle, 0, 1, 2, ma_fast);
    int ma_slow_handle = iMA(symbol, period, slow_period, 0, MODE_EMA, PRICE_CLOSE);
    CopyBuffer(ma_slow_handle, 0, 1, 2, ma_slow);

    if((BB_low[0] <= 0) || BB_up[0] <= 0)
      return;
      
    if ((ma_fast[0] < ma_slow[0]) && (PositionsTotal() > 0))
    {
      // Close All Positions
    }

    double close_price = iClose(symbol, period, 1);

    if((close_price > BB_up[0]) && (ma_fast[0] > ma_slow[0]))
     {
      BuyBuy(BB_low[0]);
     }
    else
      if((close_price > BB_low[0]) && (close_price < BB_up[0]))
       {
        if (ma_fast[0] > ma_slow[0])
        {
         BuyBuy(BB_low[0]);
        }
        if(PositionsTotal() > 0)
         {
          SellSell(BB_up[0]);
         }
       }
      else
        if((close_price < BB_low[0]) && (PositionsTotal() > 0))
         {
          SellSell(BB_up[0]);
         }
        else
          return;
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
  datetime currentOpenTime = iTime(symbol, period, 0);
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
void BuyBuy(double price)
 {

  MqlTradeRequest request;
  ZeroMemory(request);
  MqlTradeResult result;
  ZeroMemory(request);

  request.action = TRADE_ACTION_PENDING;
  request.magic = 2333;
  request.symbol = symbol;
  request.volume = lot;
  request.price = price;
  request.deviation = 5;
  request.type = ORDER_TYPE_BUY_LIMIT;
  request.type_filling = ORDER_FILLING_FOK;
  request.type_time = ORDER_TIME_GTC;

  bool res = OrderSend(request, result);
  if(!res)
   {
    Print(GetLastError());
    Print(result.retcode);
   }
 }
//+------------------------------------------------------------------+


void SellSell(double tp)
 {

  MqlTradeRequest request;
  ZeroMemory(request);
  MqlTradeResult result;
  ZeroMemory(request);

  request.action = TRADE_ACTION_SLTP;
  request.magic = 2333;
  request.symbol = symbol;
  request.deviation = 5;
  request.tp = tp;
  request.sl = tp - 1000*OnePoint;
  request.position = PositionGetTicket(0);
  request.type_filling = ORDER_FILLING_FOK;
  request.type_time = ORDER_TIME_GTC;

  bool res = OrderSend(request, result);
  if(!res)
   {
    Print(GetLastError());
    Print(result.retcode);
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

    MqlTradeRequest request;
    ZeroMemory(request);
    MqlTradeResult result;
    ZeroMemory(request);

    request.action = TRADE_ACTION_REMOVE;
    request.symbol = symbol;
    request.order = ticket;

    bool res = OrderSend(request, result);
    if(!res)
     {
      Print(GetLastError());
      Print(result.retcode);
     }

   }
 }
//+------------------------------------------------------------------+
