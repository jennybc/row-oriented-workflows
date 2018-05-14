Row-wise Summaries
================
Jenny Bryan
2018-05-14

> For rowSums, mtcars %\>% mutate(rowsum = pmap\_dbl(., sum)) works but
> is a tidy oneliner for mean or sd per row? I’m looking for a tidy
> version of rowSums, rowMeans and similarly rowSDs…

[Two](https://twitter.com/vrnijs/status/995129678284255233)
[tweets](https://twitter.com/vrnijs/status/995193240864178177) from
Vincent Nijs [github](https://github.com/vnijs),
[twitter](https://twitter.com/vrnijs)

Good question\! This also came up when I was originally casting about
for genuine row-wise operations, but I never worked it up. I will do so
now\! First I set up my example.

``` r
library(tidyverse)

df <- tribble(
  ~ name, ~ t1, ~t2, ~t3,
  "Abby",    1,   2,   3,
  "Bess",    4,   5,   6,
  "Carl",    7,   8,   9
)
```

## Use `rowSums()` and `rowMeans()` inside `dplyr::mutate()`

One “tidy version” of `rowSums()` is to … just stick `rowSums()` inside
a tidyverse pipeline. You can use `rowSums()` and `rowMeans()` inside
`mutate()`:

``` r
df %>%
  mutate(t_sum = rowSums(select_if(., is.numeric)))
#> Warning: package 'bindrcpp' was built under R version 3.4.4
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_sum
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     6
#> 2 Bess      4     5     6    15
#> 3 Carl      7     8     9    24

df %>%
  mutate(t_avg = rowMeans(select(., -name)))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8
```

Above I also demonstrate the use of `select(., SOME_EXPRESSION)` to
express which variables should be computed on. This comes up a lot in
row-wise work with a data frame, because, almost by definition, your
variables are of mixed type. These are just a few examples of the
different ways to say “use `t1`, `t2`, and `t3`”, so we don’t try to sum
or average `name`. I’ll continue to mix these in as we go. They are
equally useful when expressing which variables should be forwarded to
`.f` inside `pmap_*().`

## How to use an arbitrary function inside `pmap()`

What if you need to apply `foo()` to rows and the universe has not
provided a special-purpose `rowFoos()` function? Now you do need to use
`pmap()` or a type-stable variant, with `foo()` playing the role of
`.f`.

This works especially well with `sum()`.

``` r
df %>%
  mutate(t_sum = pmap_dbl(list(t1, t2, t3), sum))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_sum
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     6
#> 2 Bess      4     5     6    15
#> 3 Carl      7     8     9    24

df %>%
  mutate(t_sum = pmap_dbl(select(., starts_with("t")), sum))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_sum
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     6
#> 2 Bess      4     5     6    15
#> 3 Carl      7     8     9    24
```

But the original question was about means and standard deviations\! Why
is that any different? Look at the signature of `sum()` versus a few
other numerical summaries:

``` r
   sum(..., na.rm = FALSE)
  mean(x, trim = 0, na.rm = FALSE, ...)
median(x, na.rm = FALSE, ...)
   var(x, y = NULL, na.rm = FALSE, use)
```

`sum()` is especially `pmap()`-friendly because it takes `...` as its
primary argument. In contrast, `mean()` takes a vector `x` as primary
argument, which makes it harder to just drop into `pmap()`. This is
something you might never think about if you’re used to using
special-purpose helpers like `rowMeans()`.

purrr has a family of `lift_*()` functions that help you convert between
these forms. Here I apply `purrr::lift_vd()` to `mean()`, so I can use
it inside `pmap()`. The “vd” says I want to convert a function that
takes a “**v**ector” into one that takes “**d**ots”.

``` r
df %>%
  mutate(t_avg = pmap_dbl(list(t1, t2, t3), lift_vd(mean)))
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8
```

## Strategies that use reshaping and joins

Data frames simply aren’t a convenient storage format if you have a
frequent need to compute summaries, row-wise, on a subset of columns. It
is highly suggestive that your data is in the wrong shape, i.e. it’s not
tidy. Here we explore some approaches that rely on reshaping and/or
joining. They are more transparent than using `lift_*()` with `pmap()`
inside `mutate()` and, consequently, more verbose.

They all rely on forming row-wise summaries, then joining back to the
data.

### Gather, group, summarize

``` r
(s <- df %>%
    gather("time", "val", starts_with("t")) %>%
    group_by(name) %>%
    summarize(t_avg = mean(val), t_sum = sum(val)))
#> # A tibble: 3 x 3
#>   name  t_avg t_sum
#>   <chr> <dbl> <dbl>
#> 1 Abby      2     6
#> 2 Bess      5    15
#> 3 Carl      8    24
df %>%
  left_join(s)
#> Joining, by = "name"
#> # A tibble: 3 x 6
#>   name     t1    t2    t3 t_avg t_sum
#>   <chr> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2     6
#> 2 Bess      4     5     6     5    15
#> 3 Carl      7     8     9     8    24
```

### Group then summarise, with explicit `c()`

``` r
(s <- df %>%
    group_by(name) %>%
    summarise(t_avg = mean(c(t1, t2, t3))))
#> # A tibble: 3 x 2
#>   name  t_avg
#>   <chr> <dbl>
#> 1 Abby      2
#> 2 Bess      5
#> 3 Carl      8
df %>%
  left_join(s)
#> Joining, by = "name"
#> # A tibble: 3 x 5
#>   name     t1    t2    t3 t_avg
#>   <chr> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     2
#> 2 Bess      4     5     6     5
#> 3 Carl      7     8     9     8
```

### Nesting

Let’s revisit a pattern from
[`ex08_nesting-is-good`](ex08_nesting-is-good.md). This is another way
to “package” up the values of `t1`, `t2`, and `t3` in a way that make
both `mean()` and `sum()` happy. *thanks @krlmlr*

``` r
(s <- df %>%
    gather("key", "value", -name) %>%
    nest(-name) %>%
    mutate(
      sum = map(data, "value") %>% map_dbl(sum),
      mean = map(data, "value") %>% map_dbl(mean)
    ) %>%
    select(-data))
#> # A tibble: 3 x 3
#>   name    sum  mean
#>   <chr> <dbl> <dbl>
#> 1 Abby      6     2
#> 2 Bess     15     5
#> 3 Carl     24     8
df %>%
  left_join(s)
#> Joining, by = "name"
#> # A tibble: 3 x 6
#>   name     t1    t2    t3   sum  mean
#>   <chr> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 Abby      1     2     3     6     2
#> 2 Bess      4     5     6    15     5
#> 3 Carl      7     8     9    24     8
```

### Yet another way to use `rowMeans()`

``` r
(s <- df %>%
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
  left_join(s)
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
