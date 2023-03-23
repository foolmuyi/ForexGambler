// 布林带策略 - 1倍标准差

#include <Trade\Trade.mqh>


// 输入参数
input int         MA_Period   = 20;    // 移动平均线周期
input double      StdDev      = 1.0;   // 标准差

// 全局变量
double Upper_Band = 0.0;              // 上轨
double Lower_Band = 0.0;              // 下轨
int    Order_Ticket = 0;              // 订单编号

// 初始化函数
void OnInit()
{
   // 计算布林带
   Upper_Band = iMA(NULL, 0, MA_Period, 0, MODE_SMA, PRICE_CLOSE) + StdDev * iStdDev(NULL, 0, MA_Period, StdDev, MODE_SMA, PRICE_CLOSE);
   Lower_Band = iMA(NULL, 0, MA_Period, 0, MODE_SMA, PRICE_CLOSE) - StdDev * iStdDev(NULL, 0, MA_Period, StdDev, MODE_SMA, PRICE_CLOSE);
}

// 开始函数
void OnTick()
{
   double Close_Price = SymbolInfoDouble(_Symbol, SYMBOL_LAST); // 获取当前价格

   // 如果有未平仓订单，则取消订单
   if (OrderSelect(Order_Ticket))
   {
      OrderClose(Order_Ticket, OrderLots(), Bid, 3, clrRed);
   }

   // 当收盘价位于上轨上方时，以下轨价格挂买单
   if (Close_Price > Upper_Band)
   {
      Order_Ticket = OrderSend(_Symbol, OP_BUYSTOP, 0.01, Lower_Band, 3, 0, 0, "", 0, 0, clrGreen);
   }

   // 当收盘价位于上轨和下轨之间时，以上轨价挂卖单，以下轨价挂买单
   else if (Close_Price >= Lower_Band && Close_Price <= Upper_Band)
   {
      if (PositionsTotal() > 0)
      {
         OrderSend(_Symbol, OP_SELLSTOP, 0.01, Upper_Band, 3, 0, 0, "", 0, 0, clrRed);
      }
      Order_Ticket = OrderSend(_Symbol, OP_BUYSTOP, 0.01, Lower_Band, 3, 0, 0, "", 0, 0, clrGreen);
   }

   // 当收盘价位于下轨下方时，以上轨价挂卖单
   else if (Close_Price < Lower_Band)
   {
      if (PositionsTotal() > 0)
      {
         Order_Ticket = OrderSend(_Symbol, OP_SELLSTOP, 0.01, Upper_Band, 3, 0, 0, "", 0, 0, clrRed);
      }
   }
}
