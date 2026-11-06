# Datawrapper-Grafik OAVPA: Anstieg der globalen Durchschnittstemperatur
# https://app.datawrapper.de/chart/OAVPA/
#
# Hält Texte und Stil der Grafik im Repo fest. Stand im Editor am 6.11.2026,
# danach korrigiert: Untertitel (es sind Mess- und Reanalyse-Datensätze, keine
# Klimamodelle), lesbare Namen in der Legende, Hinweis auf das laufende Jahr. Die Daten lädt dieses Skript NICHT hoch: Die Grafik ist in
# Datawrapper als "externe Daten" mit der CSV im Repo verknüpft
# (output/merged_data/merged_models_data.csv, geschrieben von
# different_models_global_temp.R). Ein Daten-Upload über die API würde diese
# Verknüpfung durch eine statische Kopie ersetzen.
#
# Starten mit: LC_ALL=en_US.UTF-8 Rscript R/dw_global_temp_modelle.R
# Veröffentlicht die Grafik, solange publish unten auf TRUE steht.

devtools::load_all("/Users/rk/projects/personal/r/dw")

api_key <- dw_key_dst()
chart_id <- "OAVPA"
publish <- TRUE


# Farben ---------------------------------------------------------------------

# Drei Reihen stehen farbig in der Legende, die übrigen laufen grau mit.
# Das 99 am Ende ist Transparenz (8-stelliges Hex).
farbe_hadcrut <- "#ff6347"
farbe_noaa <- "#2f3e4d"
farbe_era5 <- "#eee8aa"
farbe_grau <- "#bcbcbc99"


# Texte ----------------------------------------------------------------------

titel <- "Anstieg der globalen Durchschnittstemperatur"

# HadCRUT5, NOAAGlobalTemp, GISTEMP und Berkeley Earth beruhen auf Messungen,
# ERA5 und JRA-55 sind Reanalysen. Keines davon ist ein Klimamodell.
intro <- paste0(
  "Abweichung der globalen Jahresmitteltemperatur vom ",
  "<b>vorindustriellen Mittel der Jahre 1850 bis 1900</b> in sechs ",
  "Datensätzen aus Messungen und Reanalysen. Die grauen Linien zeigen ",
  "GISTEMP, JRA-55 und Berkeley Earth."
)

# Geschrieben von different_models_global_temp.R; der Workflow setzt sie bei
# jedem Lauf neu
note <- paste(
  readLines("output/merged_data/datawrapper_note.txt", encoding = "UTF-8"),
  collapse = " "
)


# Linien ---------------------------------------------------------------------

# Spaltennamen der CSV sind die Schlüssel. visualize wird beim PATCH als
# Ganzes ersetzt: Alle Reihen müssen hier stehen, sonst fallen sie auf den
# Default zurück.
# title ist der Name in Legende und Tooltip; ohne ihn zeigt Datawrapper den
# Spaltennamen (z. B. "NOAAGlobalTemp")
graue_linie <- function(name) {
  list(
    title = name,
    `repeat` = list(enabled = TRUE),
    directLabel = FALSE
  )
}

linien <- list(
  HadCRUT5 = list(title = "HadCRUT5", colorKey = TRUE, directLabel = FALSE),
  NOAAGlobalTemp = list(title = "NOAA GlobalTemp", colorKey = TRUE, directLabel = FALSE),
  ERA5 = list(
    title = "ERA5",
    colorKey = TRUE,
    directLabel = FALSE,
    # Nur der jüngste ERA5-Wert bekommt eine Zahl
    valueLabels = list(first = FALSE, enabled = TRUE)
  ),
  GISTEMP = graue_linie("GISTEMP"),
  `JRA-55` = graue_linie("JRA-55"),
  BerkeleyEarth = graue_linie("Berkeley Earth")
)

# So im Editor gesetzt; mitgeführt, damit der PATCH es nicht zurücksetzt
ausgeblendetes_panel <- list(showOnMobile = FALSE, showOnDesktop = FALSE)


# Metadaten ------------------------------------------------------------------

metadata <- list(
  describe = list(
    intro = intro,
    byline = "",
    `source-name` = "Met Office",
    `source-url` = "https://climate.metoffice.cloud/dashboard.html"
  ),
  annotate = list(notes = note),
  data = list(
    `upload-method` = "external-data",
    `external-data` = "https://raw.githubusercontent.com/RobinKohrs/climateTracker/refs/heads/main/output/merged_data/merged_models_data.csv",
    `use-datawrapper-cdn` = TRUE,
    # Einheit hängt an der ersten Datenspalte und gilt so für Achse und Tooltip
    `column-format` = list(
      HadCRUT5 = list(type = "auto", ignore = FALSE, `number-append` = " °C")
    )
  ),
  publish = list(`embed-height` = 531L, `embed-width` = 600L),
  visualize = list(
    lines = linien,
    `color-category` = list(map = list(
      HadCRUT5 = farbe_hadcrut,
      NOAAGlobalTemp = farbe_noaa,
      ERA5 = farbe_era5,
      GISTEMP = farbe_grau,
      `JRA-55` = farbe_grau,
      BerkeleyEarth = farbe_grau
    )),
    panels = list(
      GISTEMP = ausgeblendetes_panel,
      `JRA-55` = ausgeblendetes_panel,
      BerkeleyEarth = ausgeblendetes_panel
    ),
    `x-grid` = "off",
    `y-grid` = "on",
    `y-grid-format` = "auto",
    `y-grid-labels` = "inside",
    `y-grid-label-align` = "left",
    `y-grid-subdivide` = TRUE,
    `custom-range-x` = list("", ""),
    `custom-range-y` = list("", ""),
    `scale-y` = "linear",
    interpolation = "linear",
    `show-tooltips` = TRUE,
    `syncMultipleTooltips` = TRUE,
    `label-colors` = FALSE,
    `value-label-colors` = TRUE,
    `connector-lines` = TRUE,
    `dark-mode-invert` = TRUE,
    `plotHeightMode` = "fixed",
    `plotHeightFixed` = 300L,
    header = list(
      style = list(fontSize = 0.9),
      borderBottom = "1px",
      borderBottomColor = "#212121"
    ),
    sharing = list(enabled = FALSE),

    # Restliche Editor-Einstellungen, unverändert übernommen. Sie stehen
    # nur hier, weil der PATCH den visualize-Block komplett ersetzt.
    `chart-type-set` = TRUE,
    `base-color` = 0L,
    `variate-colors` = FALSE,
    `colorPanelTitles` = FALSE,
    `label-margin` = 0L,
    `x-grid-format` = "auto",
    sort = list(by = "end", enabled = FALSE, reverse = FALSE),
    symbols = list(
      on = "both", size = 3.5, shape = "circle", style = "fill",
      enabled = FALSE, opacity = 1L, onRepeatedLines = TRUE
    ),
    areaFill = list(
      to = "--zero-baseline--", enabled = FALSE, opacity = 0.3,
      useLineColor = FALSE, colorNegative = "#E31A1C", useMixedColors = FALSE
    ),
    `plotHeightRatio` = 0.5,
    gridLayout = "fixedCount",
    gridColumnCount = 4L,
    gridColumnCountMobile = 2L,
    gridColumnMinWidth = 200L,
    gridRowHeightMode = "fixed",
    gridRowHeightFixed = 140L,
    gridRowHeightRatio = 1L,
    independentYScales = FALSE,
    independentYScalesRounded = TRUE,
    xGridLabelAllColumns = FALSE,
    yGridLabelAllColumns = FALSE
  )
)


# Anwenden -------------------------------------------------------------------

# Diese Grafik liegt in keinem Ordner und hat keinen custom.key, darum direkt
# über die ID und nicht über dw_create_or_update().
dw_edit_chart(
  chart_id,
  list(
    title = titel,
    theme = "der-standard-wissenschaft",
    language = "de-DE",
    metadata = metadata
  ),
  api_key
)

if (publish) {
  dw_publish(chart_id, api_key)
}

message("Aktualisiert: https://app.datawrapper.de/chart/", chart_id, "/")
