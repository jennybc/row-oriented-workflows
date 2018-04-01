#' ---
#' title: "Thinking Inside the Box"
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
#' ## Leave your data in that big, beautiful data frame

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
#' ## Add variables to a data frame

#' Using the `df$var <- ...` syntax for assignment works. But:
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

#' `dplyr::mutate()` is the tidyverse way to do this:
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

#' Q for team: Are there performance issues here?

# ----
#' ## Are you SURE you need to iterate over rows?
#'
#' Sometimes it's easy to fixate on one (unfavorable) way of accomplishing
#' something. Consider backing out and approaching from a different angle.

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
paste(df$name, "is", df$age, "years old")

#' A surprising number of "iterate over rows" problems can be solved by
#' exploiting R's propensity for vectorization. Writing a loop is not
#' necessarily bad, but it should always give you pause.

library(glue)

glue_data(df, "{name} is {age} years old")

df %>%
  mutate(sentence = glue("{name} is {age} years old"))

#' Q for team: Are there gotchas here? Has `glue()` always played this nicely
#' inside `mutate()`?

#' The tidyverse style is to manage data holistically in a data frame and
#' provide a user interface that self-explaining code with low syntactical
#' noise. self-explaining code.
