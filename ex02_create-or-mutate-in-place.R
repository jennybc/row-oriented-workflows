#' ---
#' title: "How to add or modify a variable"
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
library(tidyverse)

# ----
#' ## Function to give my example data frame
new_df <- function() {
  tribble(
    ~ name, ~ age,
    "Reed", 14,
    "Wesley", 12,
    "Eli", 12,
    "Toby", 1
  )
}

# ----
#' ## The `df$var <- ...` syntax

#' This absolutely works. But there are downsides:
#'
#'   * Silent recycling is a risk.
#'   * `df` is not special. It's not the implied place to look first for things,
#'   so you must be explicit.
#'   * I have aesthetic concerns. YMMV.
df <- new_df()
df$legs <- 4
df$snack <- c("chips", "cheese")
df$uname <- toupper(df$name)
df

# ----
#' ## `dplyr::mutate()` works "inside the box"

#' `dplyr::mutate()` is the tidyverse way to work on a variable:
#'
#'   * Only a length one input can be recycled.
#'   * `df` is the first place to look for things. It turns out that making a
#'   new variable out of existing variables is very, very common.
#'   * I like the way this looks. YMMV.
df <- new_df()
df %>%
  mutate(
    legs = 4,
    snack = c("chips", "cheese"),
    uname = toupper(name)
  )
df %>%
  mutate(
    legs = 4,
    snack = c("chips", "cheese", "mixed nuts", "nerf bullets"),
    uname = toupper(name)
  )
