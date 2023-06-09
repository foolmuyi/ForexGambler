//+------------------------------------------------------------------+
//|                                                      myVegas.mq5 |
//|                                          Copyright 2022, Lincoln |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Lincoln"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>


CSymbolInfo m_symbol;
CTrade m_trade;

input uint fast_period = 144;  // 短周期
input uint slow_period = 169;  // 长周期
input uint filter_period = 12;  // 过滤线周期

int magic_num = 2333;  // 幻数
double lot = 0.01;  // 开仓手数
const int compare_period = 24;  // 过滤线长度

ENUM_TIMEFRAMES ma_timeframe = PERIOD_H1;

CiMA ma_fast, ma_slow, ma_filter;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   m_symbol.Name(Symbol());
   m_trade.SetExpertMagicNumber(magic_num);
   m_trade.SetDeviationInPoints(50);

   ma_fast.Create(m_symbol.Name(), ma_timeframe, fast_period, 0, MODE_EMA, PRICE_CLOSE);
   ma_slow.Create(m_symbol.Name(), ma_timeframe, slow_period, 0, MODE_EMA, PRICE_CLOSE);
   ma_filter.Create(m_symbol.Name(), ma_timeframe, filter_period, 0, MODE_EMA, PRICE_CLOSE);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   MqlDateTime m_dt;
   TimeToStruct(TimeCurrent(), m_dt);
   if((m_dt.min == 0) && (m_dt.sec == 1))
     {
      ma_fast.Refresh();
      double fast_compare[];
      ma_fast.GetData(1, compare_period, 0, fast_compare);
      ArrayReverse(fast_compare, 0);

      ma_slow.Refresh();
      double slow_compare[];
      ma_slow.GetData(1, compare_period, 0, slow_compare);
      ArrayReverse(slow_compare, 0);

      ma_filter.Refresh();
      double filter_compare[];
      ma_filter.GetData(1, compare_period, 0, filter_compare);
      ArrayReverse(filter_compare, 0);

      m_symbol.RefreshRates();

      if(PositionsTotal() == 0)
        {
         bool cond_1 = CheckComparePeriod(filter_compare, fast_compare, slow_compare);
         bool cond_2 = ma_fast.Main(0) < ma_slow.Main(0);
         bool cond_3 = (High(2) > ma_fast.Main(2)) && (High(1) < ma_fast.Main(1));

         if(cond_1 && cond_2 && cond_3)
           {
            double price = m_symbol.Bid();
            m_trade.Sell(lot, m_symbol.Name(), price, ma_slow.Main(1));
           }
        }
      else
         if(PositionsTotal() == 1)
           {
            double price = m_symbol.Bid();
            double tp = m_symbol.NormalizePrice(price - 100000*m_symbol.Point());
            m_trade.PositionModify(m_symbol.Name(), ma_slow.Main(1), tp);
           }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckComparePeriod(double &filter_compare[], double &fast_compare[], double &slow_compare[])
  {
   for(int i = 0; i < compare_period; i++)
     {
      if((filter_compare[i] > fast_compare[i]) && (filter_compare[i] > slow_compare[i]))
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(const int idx)
  {
   return iOpen(m_symbol.Name(), ma_timeframe, idx);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(const int idx)
  {
   return iHigh(m_symbol.Name(), ma_timeframe, idx);
  }
//+------------------------------------------------------------------+
