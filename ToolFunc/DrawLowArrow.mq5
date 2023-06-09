//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"



const string g_symbol = "XAUUSD";
const ENUM_TIMEFRAMES g_timeframe = PERIOD_M30;

int g_counter = 0;


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

  if(IsNewCandle())
   {

    double low_price[19];
    getLowPriceArray(g_symbol, g_timeframe, low_price);
    int bars_num = ArraySize(low_price);
    int mid_index = int((bars_num)/2);

    if(ArrayMinimum(low_price) == mid_index)
     {
      datetime arrow_time = iTime(g_symbol, g_timeframe, mid_index+1);
      double arrow_price = iLow(g_symbol, g_timeframe, mid_index+1);
      ArrowBuyCreate(0, "buy_"+(string)g_counter, 0, arrow_time, arrow_price);
      g_counter++;
     }
   }

 }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowBuyCreate(const long            chart_ID=0,        // 图表 ID
                    const string          name="ArrowBuy",   // 符号名称
                    const int             sub_window=0,      // 子窗口指数
                    datetime              time=0,            // 定位点时间
                    double                price=0,           // 定位点价格
                    const color           clr=C'3,95,172',   // 符号颜色
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // 线条风格（当高亮显示时）
                    const int             width=1,           // 线条大小（当高亮显示时）
                    const bool            back=false,        // 在背景中
                    const bool            selection=false,   // 突出移动
                    const bool            hidden=true,       // 隐藏在对象列表
                    const long            z_order=0)         // 鼠标单击优先
 {
//--- 创建符号
  if(!ObjectCreate(chart_ID,name,OBJ_ARROW_BUY,sub_window,time,price))
   {
    Print(__FUNCTION__,
          ": failed to create \"Buy\" sign! Error code = ",GetLastError());
    return(false);
   }
//--- 设置符号颜色
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 设置线条风格（当高亮显示时）
  ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 设置线条大小（当高亮显示时）
  ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- 显示前景 (false) 或背景 (true)
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动符号的模式
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行
  return(true);
 }


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
int getLowPriceArray(string symbol, ENUM_TIMEFRAMES timeframe, double& low_price[])
 {
  for(int i=0; i<ArraySize(low_price); i++)
   {
    low_price[i] = iLow(symbol, timeframe, i+1);
   }
   return 0;
 }
//+------------------------------------------------------------------+
