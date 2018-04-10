# Row-oriented workflows in R with the tidyverse

Materials for [RStudio webinar](https://www.rstudio.com/resources/webinars/):

Thinking inside the box: you can do that inside a data frame?!  
Jenny Bryan  
Wednesday, April 11 at 1:00pm ET / 10:00am PT

## Abstract

The data frame is a crucial data structure in R and, especially, in the tidyverse. Working on a column or a variable is a very natural operation, which is great. But what about row-oriented work? That also comes up frequently and is more awkward. In this webinar I’ll work through concrete code examples, exploring patterns that arise in data analysis. We’ll discuss the general notion of "split-apply-combine", row-wise work in a data frame, splitting vs. nesting, and list-columns.

## Examples

Beginner --> intermediate --> advanced

  * **Leave your data in that big, beautiful data frame.** Show the evil of creating copies of certain rows of certain variables, using Magic Numbers everywhere, just to save some typing.
  * **Adding or modifying variables.** `df$var <- ...` versus `dplyr::mutate()`. Recycling/safety, `df`'s as data mask, aesthetics.
  * **Are you SURE you need to iterate over rows?** Don't fixate on most obvious generalization of your pilot example and risk overlooking a vectorized solution. Features a `paste()` example, then goes out with some glue glory.
  * **Row-wise thinking vs. column-wise thinking.** Data rectangling example. Both are possible, but I find building a tibble column-by-column is less aggravating than building rows, then row binding.
  * **Iterate over rows of a data frame.** Update and extend Winston's survey.
  * **Split-apply-combine.** Nesting vs splitting.
    - Downside of `split()`: First-class grouping variable(s) --> character vector of names --> variable is a big drag. Integer-y numerics must be coerced back, factors must be recreated, with original levels. Transitting data through attributes is an anti-pattern.
    - Downside of `nest()`: When you inspect the list-column, you can't see values of grouping (key) variables. Grouping variables not necessarily/easily available for simple map (coolbutuseless's posts and PR).

## I want help on ...

  * Am I missing patterns that are even more important/prevalent?
  * How much big picture, slides?
    - The pipe `%>%`. Does that need explicit explanation?
    - Basics of list columns and purrr's `map()` family. Whether/how to cover.
    - The lego photos stand ready.
  * Examples and/or data sets that are simpler or more delightful?
  * Anticipate tricky or good questions. Esp Qs that are both.
    - E.g., performance issues.
  * I want to have companion blog post, at the very least. Thinking bigger, this feels like something that would lend itself to a "cookbook" treatment.

## Stuff on my radar

add_row()  
rbind(df, as.data.frame(t(v2)))  
https://stackoverflow.com/questions/22581122/how-to-add-a-named-vector-as-a-row-to-a-data-frame

enframe, deframe

imap 
I'm iterating over THING but also need to know which element I'm on or element name
