data = read.csv(
  "https://sites.ecmwf.int/data/climatepulse/data/series/era5_daily_series_2t_global.csv",
  skip = 18
)

# Generate a sequence of display dates for the year 2000
display_dates = seq(as.Date("2000-01-01"), as.Date("2000-12-31"), by = "day")
display_keys = format(display_dates, "%m_%d")  # Use month_dayInMonth format

# Extract unique years from the original data
data$year = format(as.Date(data$date), "%Y")
data$key = format(as.Date(data$date), "%m_%d")  # Add a key for month_dayInMonth
unique_years = unique(data$year)

# Create an empty data frame for the result
result = data.frame(display_date = display_dates)

# Loop through each year and add its `ano_91.20` column to the result
for (year in unique_years) {
  # Subset the data for the current year
  year_data = data[data$year == year, ]

  # Match the `ano_91.20` values to the display dates using the keys
  merged_data = merge(data.frame(
    display_key = display_keys,
    display_date = display_dates
  ),
  data.frame(display_key = year_data$key, ano_91.20 = year_data$ano_91.20), by = "display_key", all.x = TRUE)

  # Add the column to the result, named by the year
  result[[year]] = merged_data$ano_91.20
}

# save the data
output_dir = file.path("output/daily_global_anomaly")
if(!dir.exists(output_dir)){
  dir.create(output_dir, recursive = T)
}

print(head(result))

output_file = file.path(output_dir, "daily_global_anomalies.csv")
write.csv(result, output_file)
