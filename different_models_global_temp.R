# URLs and model names
urls = list(
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_HadCRUT5.csv",
    name = "HadCRUT5"
  ),
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_NOAAGlobalTemp.csv",
    name = "NOAAGlobalTemp"
  ),
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_GISTEMP.csv",
    name = "GISTEMP"
  ),
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_ERA5.csv",
    name = "ERA5"
  ),
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_JRA-55.csv",
    name = "JRA-55"
  ),
  list(
    url = "https://climate.metoffice.cloud/formatted_data/gmt_Berkeley%20Earth.csv",
    name = "BerkeleyEarth"
  )
)

# Function to read and process the data
read_and_process = function(url, name) {
  data = read.csv(url)


  # Assuming the temperature data is in the second column
  model_column_name = names(data)[2]  # Adjust this if necessary

  # Return a data frame with YEAR and the model data
  return(data.frame(Year=data$Year, model_data = data[[model_column_name]]))
}

# Read data from each URL and process
all_data = lapply(urls, function(x) {
  read_and_process(x$url, x$name)
})

# Merge all data frames by the YEAR column
merged_data = all_data[[1]]
for (i in 2:length(all_data)) {
  merged_data = merge(merged_data, all_data[[i]], by = "Year", all = TRUE)
}

# Rename columns based on the model names
names(merged_data)[-1] = sapply(urls, function(x) x$name)

# Save the final result
output_dir = "output/merged_data"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Output file path
output_file = file.path(output_dir, "merged_models_data.csv")
write.csv(merged_data, output_file, row.names = FALSE)

# Print the first few rows of the result
print(head(merged_data))
