//+------------------------------------------------------------------+
//|                                                    VegasBase.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"


// configs
const string symbol = "XAUUSD";
const ENUM_TIMEFRAMES timeframe = PERIOD_M5;
const double lot = 0.01;
const uint fast_period = 144;  // 短周期
const uint slow_period = 169;  // 长周期
const uint filter_period = 12;  // 过滤线周期


// Useful global variables
double OnePoint;
double ma_fast[];
double ma_slow[];
double ma_filter[];


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
  //if(IsNewCandle())
  // {
  //  if(OrdersTotal() > 0)
  //   {
  //    CancelAllOrders();
  //   }
    
    bool ma_fast_res = FetchData(ma_fast, fast_period);
    bool ma_slow_res = FetchData(ma_slow, slow_period);
    bool ma_filter_res = FetchData(ma_filter, filter_period);
    
    Print(ma_fast_res);
    Print(ma_slow_res);
    Print(ma_filter_res);
    Print(ma_fast[0]);
    Print(ma_slow[0]);
    Print(ma_filter[0]);

   //}
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


//+------------------------------------------------------------------+
//|                                                                  |
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


bool FetchData(double &buffer[], int ma_period)
{
    int ma_handle = iMA(symbol, timeframe, ma_period, 0, MODE_EMA, PRICE_CLOSE);
    int res = CopyBuffer(ma_handle, 0, 1, 1, buffer);
    
    if ((ma_handle == INVALID_HANDLE) || (res == -1))
      return false;
    else
      return true;
}