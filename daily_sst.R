data = read.csv(
  "https://sites.ecmwf.int/data/climatepulse/data/series/era5_daily_series_sst_60S-60N_ocean.csv",
  skip = 18
)

# Generate a sequence of display dates for the year 2000
display_dates = seq(as.Date("2000-01-01"), as.Date("2000-12-31"), by = "day")
display_keys = format(display_dates, "%m_%d")  # Use month_dayInMonth format

# Extract unique years from the original data
data$year = format(as.Date(data$date), "%Y")
data$key = format(as.Date(data$date), "%m_%d")  # Add a key for month_dayInMonth
unique_years = unique(data$year)

# Helper function to build the wide-format table for a given value column
build_result = function(value_col) {
  result = data.frame(display_date = display_dates)
  for (year in unique_years) {
    year_data = data[data$year == year, ]
    merged_data = merge(
      data.frame(display_key = display_keys, display_date = display_dates),
      data.frame(display_key = year_data$key, value = year_data[[value_col]]),
      by = "display_key", all.x = TRUE
    )
    result[[year]] = merged_data$value
  }
  result
}

result_sst = build_result("sst")
result_ano = build_result("ano_91.20")

# save the data
output_dir = file.path("output/daily_sst")
if(!dir.exists(output_dir)){
  dir.create(output_dir, recursive = T)
}

write.csv(result_sst, file.path(output_dir, "daily_sst.csv"))
write.csv(result_ano, file.path(output_dir, "daily_sst_anomalies.csv"))
