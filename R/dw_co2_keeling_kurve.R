# Legt die Datawrapper-Grafik zur Keeling-Kurve an (oder bringt Stil und
# Daten auf den Stand dieses Skripts). Die laufenden Daten-Updates macht
# danach der GitHub-Workflow .github/workflows/co2_keeling.yaml.
#
# Voraussetzung: co2_keeling.R ist gelaufen (output/co2/...).
# Starten mit: LC_ALL=en_US.UTF-8 Rscript R/dw_co2_keeling_kurve.R

devtools::load_all("/Users/rk/projects/personal/r/dw")

api_key <- dw_key_dst()

# Ordner der übrigen Climate-Tracker-Grafiken (z. B. EsGwu, yOtYK)
dw_dir <- 287864

# Theme und Sprache von der Meerestemperatur-Grafik desselben Projekts
vorlage <- dw_get_chart("EsGwu", api_key)


# Daten ----------------------------------------------------------------------

co2_dw <- read.csv("output/co2/datawrapper_data.csv")
note <- paste(readLines("output/co2/datawrapper_note.txt", encoding = "UTF-8"), collapse = " ")


# Farben ---------------------------------------------------------------------

farbe_monat <- "#E59C7A"
farbe_trend <- "#A8432A"
farbe_referenz <- "#8A8A8A"


# Texte ----------------------------------------------------------------------

# Das Theme setzt den Titel in 700. Satz in 500, Kernaussage in 700.
titel_html <- function(...) {
  paste0('<span style="font-weight:500">', ..., "</span>")
}

betont <- function(text) {
  paste0('<span style="font-weight:700">', text, "</span>")
}

# Robust für eine Grafik, die sich selbst aktualisiert: keine Zahl, die
# veraltet. Geprüft: Jedes Jahresmittel seit 1959 liegt über dem Vorjahr.
# Geschützte Leerzeichen, damit „Jahr für Jahr“ auf dem Handy nicht bricht.
titel <- titel_html("Der CO<sub>2</sub>-Gehalt der Luft steigt ", betont("Jahr&nbsp;für&nbsp;Jahr"))

intro <- paste0(
  "Monatliche CO<sub>2</sub>-Konzentration der Luft am Mauna Loa auf Hawaii, ",
  "in Teilchen pro Million (ppm)"
)


# Metadaten ------------------------------------------------------------------

metadata <- list(
  describe = list(
    intro = intro,
    byline = "",
    `source-name` = "NOAA Global Monitoring Laboratory, Scripps Institution of Oceanography",
    `source-url` = "https://gml.noaa.gov/ccgg/trends/"
  ),
  annotate = list(notes = note),
  # Standardhöhe ist zu flach: Der Anstieg und die Jahreszacken gehen sonst
  # auf dem Desktop unter.
  publish = list(`embed-height` = 520L),
  visualize = list(
    # Die Spaltennamen der CSV sind die Schlüssel. Ändert co2_keeling.R sie,
    # fallen die Linien hier auf den Default zurück.
    lines = list(
      Monatsmittel = list(
        title = "Monatsmittel",
        # Normale Breite: Das Zacken-Muster der Jahreszeiten soll sichtbar
        # bleiben und nicht unter der Trendlinie verschwinden.
        colorKey = TRUE,
        directLabel = FALSE,
        # Den jüngsten Messwert als Punkt mit Zahl zeigen
        symbols = list(enabled = TRUE, on = "last", size = 5),
        valueLabels = list(first = FALSE, enabled = TRUE)
      ),
      Trend = list(
        title = "ohne jahreszeitliche Schwankung",
        width = "style3",
        colorKey = TRUE,
        directLabel = FALSE
      )
    ),
    `custom-colors` = list(
      Monatsmittel = farbe_monat,
      Trend = farbe_trend
    ),
    # Untergrenze unter 280, damit der vorindustrielle Wert ins Bild passt.
    # Obergrenze leer: wächst mit den Daten mit.
    `custom-range-y` = list("260", ""),
    `y-grid` = "on",
    `y-grid-format` = "0",
    `tooltip-number-format` = "0.0",
    `range-annotations` = list(
      list(
        type = "y",
        display = "line",
        color = farbe_referenz,
        opacity = 100L,
        position = list(y0 = 280, y1 = 280),
        strokeType = "dashed",
        strokeWidth = 1L
      )
    ),
    `text-annotations` = list(
      list(
        x = "1960-06-15",
        y = 280,
        dx = 0,
        dy = 0,
        text = "vorindustrieller Wert: rund 280 ppm",
        align = "bl",
        size = 13,
        color = farbe_referenz,
        bg = FALSE,
        bold = FALSE,
        italic = FALSE,
        underline = FALSE,
        showMobile = TRUE,
        showDesktop = TRUE,
        mobileFallback = FALSE
      )
    )
  )
)


# Anlegen oder aktualisieren -------------------------------------------------

chart_id <- dw_create_or_update(
  key = "co2_keeling_mauna_loa",
  dw_dir = dw_dir,
  title = titel,
  type = "d3-lines",
  data = co2_dw,
  metadata = metadata,
  theme = vorlage$theme,
  publish = FALSE,
  api_key = api_key
)

# Sprache gilt nicht über metadata, sondern als eigenes Feld am Chart
dw_edit_chart(chart_id, list(language = vorlage$language), api_key)
dw_publish(chart_id, api_key)

message("Chart-ID für die GitHub-Variable DW_CHART_ID_CO2: ", chart_id)
