#' ---
#' title: "Leave your data in that big, beautiful data frame"
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
#' ## Two code styles

#' Code style that results from (I speculate) minimizing the number of key
#' presses.

## :(
sl <- iris[51:100,1]
pw <- iris[51:100,4]
plot(sl ~ pw)

#' More verbose code conveys intent. Eliminating the Magic Numbers makes the
#' code less likely to be, or become, wrong.

## :) version 1
library(tidyverse)

ggplot(
  filter(iris, Species == "versicolor"),
  aes(x = Petal.Width, y = Sepal.Length)
) + geom_point()

## :) version 2, using the pipe operator, %>%
iris %>%
  filter(Species == "versicolor") %>%
  ggplot(aes(x = Petal.Width, y = Sepal.Length)) + ## <--- NOTE the `+` sign!!
  geom_point()

