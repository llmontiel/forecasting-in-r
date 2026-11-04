# forecast.R
# ----------
# Weekly demand forecasting in R using the `forecast` package.
#
# Fits two models on a training window and backtests them on a 26-week holdout:
#   1. auto.arima() — automatic ARIMA order selection
#   2. ets()        — exponential smoothing state-space model
# Both are compared against a seasonal-naive baseline (snaive), and evaluated on
# MAPE and RMSE — the metrics demand planners track.
#
# Run:
#   Rscript generate_data.R      # writes data/demand.csv
#   Rscript forecast.R           # prints metrics, writes outputs/forecast_plot.png

suppressPackageStartupMessages({
  library(forecast)
})

# ---- Load data ----
df <- read.csv("data/demand.csv", stringsAsFactors = FALSE)
y  <- ts(df$demand, frequency = 52)   # weekly series, yearly seasonality

# ---- Train / test split: last 26 weeks are the holdout ----
h <- 26
train <- head(y, length(y) - h)
test  <- tail(y, h)

# ---- Fit models on the training window ----
fit_arima <- auto.arima(train)
fit_ets   <- ets(train)

fc_arima <- forecast(fit_arima, h = h)
fc_ets   <- forecast(fit_ets,   h = h)
fc_snaive <- snaive(train, h = h)     # seasonal-naive baseline

# ---- Metrics (MAPE, RMSE) on the holdout ----
score <- function(actual, pred) {
  actual <- as.numeric(actual); pred <- as.numeric(pred)
  mape <- mean(abs((actual - pred) / actual)) * 100
  rmse <- sqrt(mean((actual - pred)^2))
  c(MAPE = round(mape, 2), RMSE = round(rmse, 1))
}

results <- rbind(
  `auto.arima`     = score(test, fc_arima$mean),
  `ets`            = score(test, fc_ets$mean),
  `seasonal-naive` = score(test, fc_snaive$mean)
)

cat("\nBacktest on a 26-week holdout\n")
cat("-----------------------------\n")
print(results)

best <- rownames(results)[which.min(results[, "MAPE"])]
cat(sprintf("\nBest model by MAPE: %s\n", best))
cat(sprintf("Selected ARIMA order: %s\n", paste(arimaorder(fit_arima), collapse = ",")))

# ---- Plot: actuals + the ARIMA forecast with prediction interval ----
dir.create("outputs", showWarnings = FALSE)
png("outputs/forecast_plot.png", width = 1000, height = 500, res = 110)
plot(fc_arima,
     main = "Weekly Demand Forecast — auto.arima (26-week horizon)",
     xlab = "Year (index)", ylab = "Demand")
lines(y, col = "black")               # overlay the full actual series
legend("topleft",
       legend = c("Actual", "ARIMA forecast", "80/95% interval"),
       col = c("black", "#2f7a3f", "grey80"),
       lwd = c(2, 2, 6), bty = "n")
invisible(dev.off())

# ---- Save metrics to CSV ----
write.csv(data.frame(model = rownames(results), results, row.names = NULL),
          "outputs/backtest_metrics.csv", row.names = FALSE)

cat("\nWrote outputs/forecast_plot.png and outputs/backtest_metrics.csv\n")
