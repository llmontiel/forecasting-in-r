# Forecasting in R

Weekly demand forecasting in R using the `forecast` package — `auto.arima` and
`ets` (exponential smoothing), backtested against a seasonal-naive baseline on a
26-week holdout. A companion to the Python forecasting engine, showing the same
problem solved with R's statistical-modeling strengths.

> Runs on fully synthetic data (no real or confidential information) and is
> reproducible end-to-end.

## What it does

```
generate_data.R  ->  data/demand.csv  ->  forecast.R  ->  outputs/
(synthetic series)                        (ARIMA + ETS + backtest + plot)
```

1. generate_data.R — simulates 3 years of weekly demand with trend, yearly
   (52-week) seasonality, and noise.
2. forecast.R — fits `auto.arima()` and `ets()` on the training window, forecasts
   the 26-week holdout, and compares both against a seasonal-naive baseline on
   MAPE and RMSE. Writes a forecast plot and a metrics CSV.

## Models

| Model | What it is |
|---|---|
| `auto.arima` | Automatic ARIMA order selection — the standard R workhorse for ARIMA |
| `ets` | Exponential smoothing state-space model (error/trend/seasonal) |
| `snaive` | Seasonal-naive baseline — "same week last year"; the honest benchmark |

Every model is scored against the seasonal-naive baseline — a forecast that
can't beat "same week last year" isn't earning its complexity.

## Run it

Requires R with the `forecast` package:

```r
install.packages("forecast")
```

```bash
Rscript generate_data.R      # writes data/demand.csv
Rscript forecast.R           # prints metrics, writes outputs/
```

Expected output — a metrics table (auto.arima / ets / seasonal-naive on MAPE and
RMSE), the best model by MAPE, the selected ARIMA order, and a forecast plot with
prediction intervals saved to `outputs/forecast_plot.png`.

## Why R here

- R's forecasting stack is best-in-class — `auto.arima` and `ets` from the
  `forecast` package (Hyndman) are the reference implementations for classical
  time-series forecasting. This project shows I reach for the right tool: Python
  for ML-feature forecasting, R for classical statistical models.
- Prediction intervals come for free — the plot shows 80%/95% intervals, which
  matter for safety-stock decisions, not just the point forecast.
- Honest backtesting — a strict holdout and a seasonal-naive benchmark, the same
  discipline applied in the Python forecasting repo.

## Repo structure

```
forecasting-in-r/
├── generate_data.R    # synthetic weekly demand generator
├── forecast.R         # auto.arima + ets + backtest + plot
├── data/              # demand.csv lands here
└── outputs/           # forecast_plot.png + backtest_metrics.csv
```

## Note

This is a companion to [demand-forecasting-engine](https://github.com/llmontiel/demand-forecasting-engine)
(the Python/ML version). Same forecasting discipline, different toolchain —
demonstrating both the ML and classical-statistical approaches to demand planning.
