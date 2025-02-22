#' Calculo del desvío estándar y el coeficiente de variación
#' @description
#' Asigna a una estimación de un total poblacional el desvío estándar o el coeficiente de variación
#' correspondiente según las tablas de error muestral de INDEC para EPH continua
#'  a partir del segundo trimestre 2003.
#' (Ver `errores_muestrales`)
#' @param value Vector numérico de las estimaciones de población para las
#' que se desea hallar el desvío estándar o el coeficiente de variación.
#' @param codigo_aglo default = "Total". String con el código numerico del aglomerado al que
#' pertenecen las estimaciones. "Total" para trabajar estimaciones del conjunto de 31 aglomerados urbanos.
#' @param periodo_eph default = "2014.03". String indicando el periodo al que corresponde la EPH. "2014.03" para
#' obtener los errores muestrales correspondientes al tercer trimestre de 2014 en adelante. "2003.03_2014.02"
#' para los errores muestrales del tercer trimestre del 2003 al segundo trimestre del 2014.
#' @param measure default = "cv". String indicando la medida que se desea obtener. "cv" para obtener el coeficiente de variación
#' correspondiente a las estimaciones o "ds" para obtener el desvío estándar.
#'
#' @return Devuelve la estimacion de un total poblacional agregando el desvio estandar o el coeficiente de variacion correspondiente segun las tablas de error muestral de INDEC para EPH continua a partir del segundo trimestre 2003
#'
#' @details disclaimer: El script no es un producto oficial de INDEC.
#'
#' @examples
#'
#' tabla <- eph::toybase_individual_2016_03 %>%
#'   eph::organize_labels() %>%
#'   dplyr::filter(AGLOMERADO == 32) %>%
#'   eph::calculate_tabulates(
#'     x = "CH03",
#'     weights = "PONDERA",
#'     add.totals = "row"
#'   )
#' tabla %>%
#'   dplyr::mutate(ds = calculate_errors(Freq,
#'     codigo_aglo = "32",
#'     periodo_eph = "2014.03", measure = "ds"
#'   ))
#'
#' @export


calculate_errors <- function(value, codigo_aglo = "Total", periodo_eph = "2014.03", measure = "cv") {

  # Controles de los parametros
  if (!is.numeric(value)) {
    cli::cli_abort(c(
      "El argumento value debe ser numeric"
    ))
  }
  if (!codigo_aglo %in% c(
    "Total", "Gran Buenos Aires", "2", "3", "5", "4", "6", "7",
    "8", "9", "10", "12", "13", "14", "15", "17", "18", "19", "20",
    "22", "23", "25", "26", "27", "29", "30", "31", "32", "33", "34",
    "36", "38", "91", "93"
  )) {
    cli::cli_abort(c(
      "Elegir alguna de las opciones de codigo_aglo: el codigo numerico del aglomerado al que pertenecen las estimaciones o 'Total' para trabajar estimaciones del conjunto de 31 aglomerados urbanos."
    ))
  }
  if (!periodo_eph %in% c("2014.03", "2003.03_2014.02")) {
    cli::cli_abort(c(
      "Elegir alguna de las opciones de periodo_eph: '2014.03' o '2003.03_2014.02'."
    ))
  }
  if (!measure %in% c("cv", "ds")) {
    cli::cli_abort(c(
      "Elegir alguna de las opciones de measure: 'cv' o 'ds'."
    ))
  }

  # Operacion
  tabla_referencia <- eph::errores_muestrales %>%
    dplyr::filter(codigo == codigo_aglo & periodo == periodo_eph) %>%
    dplyr::select(x, measure)

  find_closest <- function(y) {
    tabla_referencia[[measure]][which.min(abs(tabla_referencia[["x"]] - y))]
  }

  vapply(value, FUN = find_closest, FUN.VALUE = numeric(1))
}
