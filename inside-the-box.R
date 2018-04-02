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
library(tidyverse)


# ----
#' ## If you must sweat, compare row-wise work vs. column-wise work
#'
#' The approach you use in that first example is not always the one that scales
#' up the best.

sapply(df, class)
class(df[1, ])
class(iris[14, ])

x <- list(
  list(name = "sue", number = 1, veg = c("onion", "carrot")),
  list(name = "doug", number = 2, veg = c("potato", "beet"))
)

# row binding

# frustrating base attempts
rbind(x)
do.call(rbind, x)
do.call(rbind, x) %>% str()

# tidyverse fail
bind_rows(x)
map_dfr(x, ~ .x)

map_dfr(x, ~ .x[c("name", "number")])

tibble(
  name = map_chr(x, "name"),
  number = map_dbl(x, "number"),
  veg = map(x, "veg")
)

# add_row()
# rbind(df, as.data.frame(t(v2)))
# https://stackoverflow.com/questions/22581122/how-to-add-a-named-vector-as-a-row-to-a-data-frame

## iterating over rows
## specific problem from dean: transforming a dataframe into a list of rows
## (the format that Javascript d3 expects)
# split(x, seq_len(nrow(x))) then lapply (or purrr::map)
# lapply(seq_len(nrow(df)), function(i) as.list(df[i,,drop=F]))
# for (i in seq_len(nrow(df)) {...}
# for(i in seq_along(df[,1]){df[i,]}
# lapply(seq(nrow(df)), function(i) { row <- df[i,] }
# ## jim hester
# lapply(seq_len(NROW(df)), function(i) val = df[i, , drop = FALSE])

pmap(head(iris), list)

View(mtcars)
