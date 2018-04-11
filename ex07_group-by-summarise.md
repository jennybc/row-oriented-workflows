Work on groups of rows via dplyr::group\_by() + summarise()
================
Jenny Bryan
2018-04-10

What if you need to work on groups of rows? Such as the groups induced
by the levels of a factor.

You do not need to … split the data frame into mini-data-frames, loop
over them, and glue it all back together.

Instead, use `dplyr::group_by()`, followed by `dplyr::summarize()`, to
compute group-wise summaries.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

iris %>%
  group_by(Species) %>%
  summarise(pl_avg = mean(Petal.Length), pw = mean(Petal.Width))
#> # A tibble: 3 x 3
#>   Species    pl_avg    pw
#>   <fct>       <dbl> <dbl>
#> 1 setosa       1.46 0.246
#> 2 versicolor   4.26 1.33 
#> 3 virginica    5.55 2.03
```

What if you want to return summaries that are not just a single number?

This does not “just work”.

``` r
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = quantile(Petal.Length, c(0.25, 0.5, 0.75)))
#> Error in summarise_impl(.data, dots): Column `pl_qtile` must be length 1 (a summary value), not 3
```

Solution: package as a length-1 list that contains 3 values, creating a
list-column.

``` r
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = list(quantile(Petal.Length, c(0.25, 0.5, 0.75))))
#> # A tibble: 3 x 2
#>   Species    pl_qtile 
#>   <fct>      <list>   
#> 1 setosa     <dbl [3]>
#> 2 versicolor <dbl [3]>
#> 3 virginica  <dbl [3]>
```
