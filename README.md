# Row-oriented workflows in R with the tidyverse

Materials for [RStudio webinar](https://www.rstudio.com/resources/webinars/):

Thinking inside the box: you can do that inside a data frame?!  
Jenny Bryan  
Wednesday, April 11 at 1:00pm ET / 10:00am PT

## Abstract

The data frame is a crucial data structure in R and, especially, in the tidyverse. Working on a column or a variable is a very natural operation, which is great. But what about row-oriented work? That also comes up frequently and is more awkward. In this webinar I’ll work through concrete code examples, exploring patterns that arise in data analysis. We’ll discuss the general notion of "split-apply-combine", row-wise work in a data frame, splitting vs. nesting, and list-columns.

## Code examples

Beginner --> intermediate --> advanced  
Not all are used in webinar

  * **Leave your data in that big, beautiful data frame.** [`ex01_leave-it-in-the-data-frame`](ex01_leave-it-in-the-data-frame.md) Show the evil of creating copies of certain rows of certain variables, using Magic Numbers and cryptic names, just to save some typing.
  * **Adding or modifying variables.** [`ex02_create-or-mutate-in-place`](ex02_create-or-mutate-in-place.md) `df$var <- ...` versus `dplyr::mutate()`. Recycling/safety, `df`'s as data mask, aesthetics.
  * **Are you SURE you need to iterate over rows?** [`ex03_row-wise-iteration-are-you-sure`](ex03_row-wise-iteration-are-you-sure.md) Don't fixate on most obvious generalization of your pilot example and risk overlooking a vectorized solution. Features a `paste()` example, then goes out with some glue glory.
  * **Row-wise thinking vs. column-wise thinking.** [`ex04_attack-via-rows-or-columns`](ex04_attack-via-rows-or-columns.md) Data rectangling example. Both are possible, but I find building a tibble column-by-column is less aggravating than building rows, then row binding.
  * **Iterate over rows of a data frame.** [`iterate-over-rows`](iterate-over-rows.md) Empirical study of reshaping a data frame into this form: a list with one component per row. Revisiting a study originally done by Winston Chang. Run times for different number of [rows](row-benchmark.png) or [columns](col-benchmark.png).
  * **Split-apply-combine.** Nesting vs splitting.
    - Downside of `split()`: First-class grouping variable(s) --> character vector of names --> variable is a big drag. Integer-y numerics must be coerced back, factors must be recreated, with original levels. Transitting data through attributes is an anti-pattern.
    - Downside of `nest()`: When you inspect the list-column, you can't see values of grouping (key) variables. Grouping variables not necessarily/easily available for simple map (coolbutuseless's posts and PR).
