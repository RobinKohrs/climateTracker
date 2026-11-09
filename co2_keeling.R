# Keeling-Kurve: monatliche CO2-Konzentration am Mauna Loa (Hawaii)
#
# Quelle: NOAA Global Monitoring Laboratory (Lan, Thoning & Keeling),
#   "Trends in Atmospheric Carbon Dioxide", Monthly mean CO2 at Mauna Loa
#   https://gml.noaa.gov/ccgg/trends/
#   Datei: https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.csv
#
# Warum diese Datei: Sie enthält die komplette Mauna-Loa-Reihe ab März 1958 in
# einer Tabelle (bis April 1974 Messungen der Scripps Institution of
# Oceanography, danach NOAA). So wird keine Einzelstation mit einem globalen
# Mittelwert verklebt.
#
# Besonderheiten laut Dateikopf:
# - Fehlende Monate hat NOAA interpoliert; erkennbar an negativer sdev/unc.
#   Bei den Scripps-Daten (bis 1974) sind diese Felder immer negativ, weil es
#   dazu keine Angaben gibt – dort heißt "negativ" also nicht "interpoliert".
# - Dezember 2022 bis Juli 2023 stammen die Messungen vom Maunakea (ca. 34 km
#   nördlich), weil der Mauna Loa ausgebrochen war.
#
# Bewusst nur Base R: Der GitHub-Workflow muss so keine Pakete installieren.

source_url = "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.csv"
output_dir = "output/co2"
output_file = file.path(output_dir, "co2_mauna_loa_monthly.csv")
datawrapper_file = file.path(output_dir, "datawrapper_data.csv")
note_file = file.path(output_dir, "datawrapper_note.txt")

download_noaa_csv = function(url, attempts = 3L, retry_delay = 5) {
  path = tempfile()
  on.exit(unlink(path))

  for (attempt in seq_len(attempts)) {
    unlink(path)
    status = tryCatch(
      utils::download.file(url, path, method = "libcurl", quiet = TRUE, mode = "wb"),
      error = function(e) NA_integer_
    )
    if (isTRUE(status == 0L) && file.exists(path) && isTRUE(file.info(path)$size > 0)) {
      return(read.csv(path, comment.char = "#", check.names = FALSE))
    }

    if (attempt < attempts) {
      message("NOAA CSV download failed (attempt ", attempt, " of ", attempts, "); retrying in ", retry_delay, " seconds.")
      Sys.sleep(retry_delay)
    }
  }

  stop("Could not download NOAA CO2 data after ", attempts, " attempts: ", url)
}

co2_raw = download_noaa_csv(source_url)


# Plausibilitätsprüfungen ---------------------------------------------------
# Lieber den Workflow abbrechen, als kaputte Daten in eine Live-Grafik zu
# schieben. Bricht das Skript ab, wird nichts committet oder veröffentlicht.

expected_columns = c("year", "month", "average", "deseasonalized", "sdev")
missing_columns = setdiff(expected_columns, names(co2_raw))
if (length(missing_columns) > 0) {
  stop("Spalten fehlen in der NOAA-Datei: ", paste(missing_columns, collapse = ", "))
}

# Ältere Dateiversionen codierten Lücken als -99.99
co2_raw$average[co2_raw$average < 0] = NA
co2_raw$deseasonalized[co2_raw$deseasonalized < 0] = NA

stopifnot(
  "Weniger Monate als erwartet" = nrow(co2_raw) > 800,
  "Reihe beginnt nicht im März 1958" = co2_raw$year[1] == 1958 && co2_raw$month[1] == 3,
  "Doppelte Monate" = !anyDuplicated(co2_raw[c("year", "month")]),
  "Monatsmittel fehlen" = !anyNA(co2_raw$average),
  "Werte außerhalb von 300–500 ppm" = all(co2_raw$average > 300 & co2_raw$average < 500)
)


# Aufbereiten ----------------------------------------------------------------

# Interpolation ist nur ab der NOAA-Zeit (Mai 1974) aus sdev ablesbar
is_noaa_period = co2_raw$year > 1974 | (co2_raw$year == 1974 & co2_raw$month >= 5)

co2 = data.frame(
  # Monatsmitte, weil NOAA die Werte auf die Monatsmitte zentriert
  datum = as.Date(sprintf("%d-%02d-15", co2_raw$year, co2_raw$month)),
  monatsmittel_ppm = co2_raw$average,
  saisonbereinigt_ppm = co2_raw$deseasonalized,
  interpoliert = ifelse(is_noaa_period, co2_raw$sdev < 0, NA)
)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(co2, output_file, row.names = FALSE)

# Eigene, schlanke Datei für Datawrapper. Die Spaltennamen sind zugleich die
# Schlüssel der Linien-Einstellungen im Chart (lines.Monatsmittel usw.) und
# dürfen sich daher nicht ändern.
co2_datawrapper = data.frame(
  Datum = co2$datum,
  Monatsmittel = co2$monatsmittel_ppm,
  Trend = co2$saisonbereinigt_ppm
)
write.csv(co2_datawrapper, datawrapper_file, row.names = FALSE, quote = FALSE)


# Anmerkungstext für Datawrapper --------------------------------------------
# Monatsnamen fest auf Deutsch, damit das Ergebnis nicht vom Locale des
# GitHub-Runners abhängt.

monate = c(
  "Jänner", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember"
)
letzte_zeile = co2_raw[nrow(co2_raw), ]

# Messort und Scripps stehen schon in Untertitel und Quellenzeile
note = paste0(
  "Letzter Messwert: <strong>", monate[letzte_zeile$month], " ",
  letzte_zeile$year, "</strong>. Von Dezember 2022 bis Juli 2023 wurde am ",
  "nahen Maunakea gemessen, weil der Mauna Loa ausgebrochen war. Der ",
  "vorindustrielle Wert von rund 280 ppm stammt aus Eisbohrkernen."
)
writeLines(note, note_file)

message(
  "CO2-Daten geschrieben: ", nrow(co2), " Monate, ",
  format(min(co2$datum), "%m/%Y"), " bis ", format(max(co2$datum), "%m/%Y"),
  ", letzter Wert ", letzte_zeile$average, " ppm"
)
