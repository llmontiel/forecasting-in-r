# generate_data.R
# ---------------
# Generate a synthetic weekly demand series and write it to data/demand.csv.
# Trend + yearly (52-week) seasonality + noise — the shape a real grocery
# category's demand follows. No real or confidential data.
#
# Run:  Rscript generate_data.R

set.seed(7)

n_weeks <- 156                      # 3 years of weekly data
t <- 0:(n_weeks - 1)

trend     <- 500 + 1.5 * t
seasonal  <- 80 * sin(2 * pi * t / 52)
noise     <- rnorm(n_weeks, mean = 0, sd = 40)
demand    <- pmax(0, round(trend + seasonal + noise))

start_date <- as.Date("2023-01-02")           # a Monday
week_dates <- start_date + 7 * t

df <- data.frame(week_start = week_dates, demand = demand)

dir.create("data", showWarnings = FALSE)
write.csv(df, "data/demand.csv", row.names = FALSE)

cat(sprintf("Wrote data/demand.csv — %d weekly observations (%s to %s).\n",
            nrow(df), min(df$week_start), max(df$week_start)))
cat(sprintf("Demand range: %d to %d, mean %.0f\n",
            min(df$demand), max(df$demand), mean(df$demand)))
