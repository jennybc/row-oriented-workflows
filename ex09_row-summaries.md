Row-wise Summaries
================
Jenny Bryan
2018-05-12

> For rowSums, mtcars %\>% mutate(rowsum = pmap\_dbl(., sum)) works but
> is a tidy oneliner for mean or sd per row? I’m looking for a tidy
> version of rowSums, rowMeans and similarly rowSDs…

[Two](https://twitter.com/vrnijs/status/995129678284255233)
[tweets](https://twitter.com/vrnijs/status/995193240864178177) from
Vincent Nijs [github](https://github.com/vnijs),
[twitter](https://twitter.com/vrnijs)

Good question\! This also came up when I was originally casting about
for genuine row-wise operations, but I never worked it up. I will do so
now\!

``` r
library(tidyverse)

df <- tribble(
  ~ name, ~ t1, ~t2, ~t3,
  "Abby",    1,   2,   3,
  "Bess",    4,   5,   6,
  "Carl",    7,   8,   9
)
```

Here is a one-liner, but my use of `purrr::lift_vd()` makes it a little
astronaut-y..

``` r
df %>%
  mutate(t_avg = pmap_dbl(select(., -name), lift_vd(mean)))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8
```

Interestingly, you don’t need to change the domain for `sum()`:

``` r
df %>%
  mutate(t_sum = pmap_dbl(select(., -name), sum))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_sum
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     6
#> 2 Bess      4     5     6    15
#> 3 Carl      7     8     9    24
```

Why is that? Because of the difference in signature of `sum()` and
`mean()`:

``` r
sum(..., na.rm = FALSE)
mean(x, ...)
```

`sum()` has a more favorable signature for the way `purrr::pmap()`
presents the data from each row.

Note that above I’m also showing the use of `select(., SOME EXPRESSION)`
to take control over which variables are passed along to `.f` of
`pmap()`.

## Joining summaries back in

Data frames simply aren’t a convenient storage format if you have a
frequent need to compute summaries, row-wise, on a subset of columns.
This might suggest that your data is in the wrong shape. In any case,
the more transparent ways to do this are also more verbose. More verbose
patterns for this involve using `group_by()` + `summarise()` and,
therefore, obligate you to computing summaries separately and joining
back in.

``` r
(s1 <- df %>%
    group_by(name) %>%
    summarise(t_avg = mean(c(t1, t2, t3))))
#> # A tibble: 3 x 2
#>   name  t_avg
#>   <chr> <dbl>
#> 1 Abby      2
#> 2 Bess      5
#> 3 Carl      8
df %>%
  left_join(s1)
#> Joining, by = "name"
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8

(s2 <- df %>%
    gather("time", "val", starts_with("t")) %>%
    group_by(name) %>%
    summarize(t_avg = mean(val)))
#> # A tibble: 3 x 2
#>   name  t_avg
#>   <chr> <dbl>
#> 1 Abby      2
#> 2 Bess      5
#> 3 Carl      8
df %>%
  left_join(s2)
#> Joining, by = "name"
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8

(s3 <- df %>%
    column_to_rownames("name") %>%
    rowMeans() %>%
    enframe())
#> Warning: Setting row names on a tibble is deprecated.
#> # A tibble: 3 x 2
#>   name  value
#>   <chr> <dbl>
#> 1 Abby      2
#> 2 Bess      5
#> 3 Carl      8
df %>%
  left_join(s3)
#> Joining, by = "name"
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 value
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8
```

## Maybe you should use a matrix

If you truly have data where each row is:

  - Identifier for this observational unit
  - Homogeneous vector of length n for the unit

then you do want to use a matrix with rownames. I used to do this alot
but found that practically none of my data analysis problems live in
this simple world for more than a couple of hours. Eventually I always
get back to a setting where a data frame is the most favorable
receptacle, overall. YMMV.

``` r
m <- matrix(
  1:9,
  byrow = TRUE, nrow = 3,
  dimnames = list(c("Abby", "Bess", "Carl"), paste0("t", 1:3))
)

cbind(m, rowsum = rowSums(m))
#>      t1 t2 t3 rowsum
#> Abby  1  2  3      6
#> Bess  4  5  6     15
#> Carl  7  8  9     24
cbind(m, rowmean = rowMeans(m))
#>      t1 t2 t3 rowmean
#> Abby  1  2  3       2
#> Bess  4  5  6       5
#> Carl  7  8  9       8
```
