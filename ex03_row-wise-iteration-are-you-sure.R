#' ---
#' title: "Are you absolutely SURE you need to iterate over rows?"
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
#' ## Single-row example can cause tunnel vision
#'
#' Sometimes it's easy to fixate on one (unfavorable) way of accomplishing
#' something, because it feels like a natural extension of a successful
#' small-scale experiment.

#' Start with a small example, row 1 of the data frame.
df <- new_df()
paste(df$name[1], "is", df$age[1], "years old")

#' I want to scale up, therefore I must ... loop over all rows!
n <- nrow(df)
for (i in seq_len(n)) {
  cat(paste(df$name[i], "is", df$age[i], "years old"), sep = "\n")
}

#' HOLD ON. What if I told you `paste()` is already vectorized over its
#' arguments?
paste(df$name, "is", df$age, "years old") %>% cat(sep = "\n")

#' A surprising number of "iterate over rows" problems can be solved by
#' exploiting functions that are already vectorized and by making your own
#' functions vectorized over the primary argument. Writing a loop is not
#' necessarily bad, but it should always give you pause.

#' Even better: work with a natively vectorized function that knows about your
#' data frame!
library(glue)

glue_data(df, "{name} is {age} years old")

df %>%
  mutate(sentence = glue("{name} is {age} years old"))

#' The tidyverse style is to manage data holistically in a data frame and
#' provide a user interface that encourages self-explaining code with low
#' "syntactical noise".
#'
#' Q for team: Are there gotchas here? Has `glue()` always played this nicely
#' inside `mutate()`?
