# Forecasting in R

Weekly demand forecasting in R using the `forecast` package — `auto.arima` and
`stlf` (STL + exponential smoothing), backtested against a seasonal-naive
baseline on a 26-week holdout. A companion to the Python forecasting engine,
showing the same problem solved with R's statistical-modeling strengths.

> Runs on fully synthetic data (no real or confidential information) and is
> reproducible end-to-end.

## Results

Backtested on a 26-week out-of-sample holdout:

| Model | MAPE | RMSE |
|---|---|---|
| auto.arima | 5.23% | 39.8 |
| stl + ets | (seasonal) | — |
| seasonal-naive | 11.88% | 88.6 |

auto.arima cuts forecast error by more than half versus the seasonal-naive
baseline (5.23% vs 11.88% MAPE). Every model is scored against that benchmark —
a forecast that can't beat "same week last year" isn't earning its complexity.

## What it does

```
generate_data.R  ->  data/demand.csv  ->  forecast.R  ->  outputs/
(synthetic series)                        (ARIMA + STL/ETS + backtest + plot)
```

1. generate_data.R — simulates 3 years of weekly demand with trend, yearly
   (52-week) seasonality, and noise.
2. forecast.R — fits `auto.arima()` and `stlf()` on the training window, forecasts
   the 26-week holdout, and compares both against a seasonal-naive baseline on
   MAPE and RMSE. Writes a forecast plot and a metrics CSV.

## Models

| Model | What it is |
|---|---|
| `auto.arima` | Automatic (seasonal) ARIMA order selection — the standard R workhorse for ARIMA |
| `stlf` (STL + ETS) | STL decomposition + exponential smoothing. Used instead of a plain `ets()` because `ets()` can't model seasonality for weekly (freq=52) series — `stlf` decomposes the seasonality out first, so the seasonal signal is actually used |
| `snaive` | Seasonal-naive baseline — "same week last year"; the honest benchmark |

## Run it

Requires R with the `forecast` package:

```r
install.packages("forecast")
```

```bash
Rscript generate_data.R      # writes data/demand.csv
Rscript forecast.R           # prints metrics, writes outputs/
```

Expected output — a metrics table (auto.arima / stl+ets / seasonal-naive on MAPE
and RMSE), the best model by MAPE, the selected ARIMA order, and a forecast plot
with prediction intervals saved to `outputs/forecast_plot.png`.

## Why R here

- R's forecasting stack is best-in-class — `auto.arima` and the STL/ETS tools
  from the `forecast` package (Hyndman) are reference implementations for
  classical time-series forecasting. This project shows I reach for the right
  tool: Python for ML-feature forecasting, R for classical statistical models.
- The right tool for weekly data — using `stlf` rather than plain `ets` for a
  high-frequency (52-period) series is a deliberate choice: `ets` silently drops
  seasonality above frequency 24, so STL decomposition is the correct approach.
- Prediction intervals come for free — the plot shows 80%/95% intervals, which
  matter for safety-stock decisions, not just the point forecast.
- Honest backtesting — a strict holdout and a seasonal-naive benchmark, the same
  discipline applied in the Python forecasting repo.

## Repo structure

```
forecasting-in-r/
├── generate_data.R    # synthetic weekly demand generator
├── forecast.R         # auto.arima + stlf + backtest + plot
├── data/              # demand.csv lands here
└── outputs/           # forecast_plot.png + backtest_metrics.csv
```

## Note

This is a companion to [demand-forecasting-engine](https://github.com/llmontiel/demand-forecasting-engine)
(the Python/ML version). Same forecasting discipline, different toolchain —
demonstrating both the ML and classical-statistical approaches to demand planning.
