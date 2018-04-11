#' ---
#' title: "Work on groups of rows via dplyr::group_by() + summarise()"
#' author: "Jenny Bryan"
#' date: "`r format(Sys.Date())`"
#' output: github_document
#' ---

#+ setup, include = FALSE, cache = FALSE
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
options(tidyverse.quiet = TRUE)

#+ body
# ----

#' What if you need to work on groups of rows? Such as the groups induced by
#' the levels of a factor.
#'
#' You do not need to ... split the data frame into mini-data-frames, loop over
#' them, and glue it all back together.
#'
#' Instead, use `dplyr::group_by()`, followed by `dplyr::summarize()`, to
#' compute group-wise summaries.

library(dplyr)

iris %>%
  group_by(Species) %>%
  summarise(pl_avg = mean(Petal.Length), pw = mean(Petal.Width))

#' What if you want to return summaries that are not just a single number?
#'
#' This does not "just work".
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = quantile(Petal.Length, c(0.25, 0.5, 0.75)))

#' Solution: package as a length-1 list that contains 3 values, creating a
#' list-column.
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = list(quantile(Petal.Length, c(0.25, 0.5, 0.75))))
