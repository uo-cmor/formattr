###################################################################
### Number formatting functions (based on scales::number() etc) ###
###################################################################

#' Format numbers using `scales::number()`-type functions
#'
#' These functions replace/extend the `scales::number()-type` formatting
#'     functions.
#'
#' @param x Numeric vector to format
#' @param accuracy,scale,prefix,suffix,big.mark,decimal.mark,... As in
#'     \code{\link[scales]{number}}. If a vector is supplied, will be applied
#'     element-wise to `x` (and must have the same length as `x`).
#' @param html Logical scalar. Whether to include formatting marks (minus
#'     signs and narrow spaces between digits) as HTML strings (the default;
#'     best for Word or HTML output documents) or unicode.
#' @param na String scalar
#'
#' @name number-formatting
NULL

#' @rdname number-formatting
#' @export
nmbr <- function(x, accuracy = 1, scale = 1, prefix = "", suffix = "",
                 big.mark = "< >", decimal.mark = ".", html = TRUE, na = NA_character_,
                 ...) {
  if (length(x) == 0) return(character())
  args <- lapply(match.call()[-1], eval)
  check_nmbr_args(args)

  x <- round(x*scale/accuracy) * accuracy/scale

  minus <- if (html) "&minus;" else "\u2212"
  neg <- rep("", length(x))
  neg[x < 0] <- minus

  narrow_space <- if (html) "&#x202F;" else "\u202F"

  if (any(lengths(args[-1]) > 1)) {
    accuracy <- rlang::rep_along(x, accuracy)
    scale <- rlang::rep_along(x, scale)
    big.mark <- rlang::rep_along(x, big.mark)
    decimal.mark <- rlang::rep_along(x, decimal.mark)

    nsmall <- pmin(pmax(-floor(log10(accuracy)), 0), 20)

    frmt <- vapply(
      seq_along(x),
      function(i) format(abs(scale[i] * x[i]), big.mark = big.mark[i],
                         decimal.mark = decimal.mark[i], trim = TRUE, nsmall = nsmall[i],
                         scientific = FALSE, ...),
      character(1)
    )
  } else {
    nsmall <- min(max(-floor(log10(accuracy)), 0), 20)

    frmt <- format(abs(scale * x), big.mark = big.mark, decimal.mark = decimal.mark, trim = TRUE,
                   nsmall = nsmall, scientific = FALSE, ...)
  }

  ret <- stringi::stri_replace_all_regex(paste0(neg, prefix, frmt, suffix), "< >", narrow_space)
  ret[is.na(x)] <- na
  names(ret) <- names(x)
  ret
}

check_nmbr_args <- function(args) {
  if (!rlang::is_bare_numeric(eval(args$x))) stop_wrong_type("x", "a numeric vector")
  lenx <- length(args$x)

  if (!is.null(args$accuracy) && !rlang::is_bare_numeric(args$accuracy))
    stop_wrong_type("accuracy", "a numeric vector/scalar")
  if (!is.null(args$scale) && !rlang::is_bare_numeric(args$scale))
    stop_wrong_type("scale", "a numeric vector/scalar")
  if (!is.null(args$prefix) && !rlang::is_bare_character(args$prefix))
    stop_wrong_type("prefix", "a character vector/scalar")
  if (!is.null(args$suffix) && !rlang::is_bare_character(args$suffix))
    stop_wrong_type("suffix", "a character vector/scalar")
  if (!is.null(args$big.mark) && !rlang::is_bare_character(args$big.mark))
    stop_wrong_type("big.mark", "a character vector/scalar")
  if (!is.null(args$decimal.mark) && !rlang::is_bare_character(args$decimal.mark))
    stop_wrong_type("decimal.mark", "a character vector/scalar")

  if (!is.null(args$html) && !rlang::is_bool(args$html))
    stop_wrong_type("html", "`TRUE`/`FALSE`")
  if (!is.null(args$na) && !rlang::is_scalar_character(args$na))
    stop_wrong_type("na", "a string scalar")

  if (!is.null(args$accuracy) && length(args$accuracy) != 1 && length(args$accuracy) != lenx)
    stop_wrong_length("accuracy", lenx, length(args$accuracy))
  if (!is.null(args$scale) && length(args$scale) != 1 && length(args$scale) != lenx)
    stop_wrong_length("scale", lenx, length(args$scale))
  if (!is.null(args$prefix) && length(args$prefix) != 1 && length(args$prefix) != lenx)
    stop_wrong_length("prefix", lenx, length(args$prefix))
  if (!is.null(args$suffix) && length(args$suffix) != 1 && length(args$suffix) != lenx)
    stop_wrong_length("suffix", lenx, length(args$suffix))
  if (!is.null(args$big.mark) && length(args$big.mark) != 1 && length(args$big.mark) != lenx)
    stop_wrong_length("big.mark", lenx, length(args$big.mark))
  if (!is.null(args$decimal.mark) && length(args$decimal.mark) != 1
      && length(args$decimal.mark) != lenx)
    stop_wrong_length("decimal.mark", lenx, length(args$decimal.mark))
}