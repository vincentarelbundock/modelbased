#' @keywords internal
.get_marginalmeans <- function(model,
                               at = "auto",
                               fixed = NULL,
                               transform = "response",
                               ci = 0.95,
                               ...) {
  # check if available
  insight::check_if_installed("marginaleffects")

  # Guess arguments
  args <- .guess_emmeans_arguments(model, at, fixed, ...)

  # Run emmeans
  means <- marginaleffects::marginalmeans(model, variables = args$at, conf_level = ci)

  # TODO: this should be replaced by parameters::parameters(means)
  # Format names
  names(means)[names(means) %in% "conf.low"] <- "CI_low"
  names(means)[names(means) %in% "conf.high"] <- "CI_high"
  names(means)[names(means) %in% "std.error"] <- "SE"
  names(means)[names(means) %in% "marginalmean"] <- "Mean"
  names(means)[names(means) %in% "p.value"] <- "p"
  names(means)[names(means) %in% "statistic"] <- ifelse(insight::find_statistic(model) == "t-statistic", "t", "statistic")

  # Format terms
  term <- unique(means$term) # Get name of variable
  if (length(term) > 1L) {
    insight::format_error("marignalmeans backend can currently only deal with one 'at' variable.")
  }
  names(means)[names(means) %in% c("value")] <- term # Replace 'value' col by var name
  means$term <- NULL

  # Drop stats
  means$p <- NULL
  means$t <- NULL

  # Store attributes
  attr(means, "at") <- args$at

  means
}
