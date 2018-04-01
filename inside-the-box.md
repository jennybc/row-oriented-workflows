Thinking Inside the Box
================
Jenny Bryan
2018-03-31

## Leave your data in that big, beautiful data frame

Code style that results from (I speculate) minimizing the number of key
presses.

``` r
## NO
sl <- iris[51:100,1]
pw <- iris[51:100,4]
plot(sl ~ pw)
```

![](inside-the-box_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

More verbose code conveys intent. Eliminating the Magic Numbers makes
the code less likely to be, or become, wrong.

``` r
## YES, version 1
library(tidyverse)

ggplot(
  filter(iris, Species == "versicolor"),
  aes(x = Petal.Width, y = Sepal.Length)
) + geom_point()
```

![](inside-the-box_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r

## YES, version 2, using the pipe operator, %>%
iris %>%
  filter(Species == "versicolor") %>%
  ggplot(aes(x = Petal.Width, y = Sepal.Length)) + ## <--- NOTE the `+` sign!!
  geom_point()
```

![](inside-the-box_files/figure-gfm/unnamed-chunk-3-2.png)<!-- -->

## Function to give my example data frame

``` r
new_df <- function() {
  tribble(
    ~ name, ~ age,
    "Reed", 14,
    "Wesley", 12,
    "Eli", 12,
    "Toby", 1
  )
}
```

## Add variables to a data frame

Using the `df$var <- ...` syntax for assignment works. But:

  - Silent recycling is a risk.
  - `df` is not special. It’s not the implied place to look first for
    things, so you must be explicit.
  - I have aesthetic concerns. YMMV.

<!-- end list -->

``` r
df <- new_df()
df$legs <- 4
df$snack <- c("chips", "cheese")
df$uname <- toupper(df$name)
df
#> # A tibble: 4 x 5
#>   name     age  legs snack  uname 
#>   <chr>  <dbl> <dbl> <chr>  <chr> 
#> 1 Reed     14.    4. chips  REED  
#> 2 Wesley   12.    4. cheese WESLEY
#> 3 Eli      12.    4. chips  ELI   
#> 4 Toby      1.    4. cheese TOBY
```

`dplyr::mutate()` is the tidyverse alternative:

  - Only a length one input can be recycled.
  - `df` is the first place to look for things. It turns out that making
    a new variable using existing variables is very, very common.
  - I like the way this looks. YMMV.

<!-- end list -->

``` r
df <- new_df()
df %>%
  mutate(
    legs = 4,
    snack = c("chips", "cheese"),
    uname = toupper(name)
  )
#> Error in mutate_impl(.data, dots): Column `snack` must be length 4 (the number of rows) or one, not 2
df %>%
  mutate(
    legs = 4,
    snack = c("chips", "cheese", "mixed nuts", "nerf bullets"),
    uname = toupper(name)
  )
#> # A tibble: 4 x 5
#>   name     age  legs snack        uname 
#>   <chr>  <dbl> <dbl> <chr>        <chr> 
#> 1 Reed     14.    4. chips        REED  
#> 2 Wesley   12.    4. cheese       WESLEY
#> 3 Eli      12.    4. mixed nuts   ELI   
#> 4 Toby      1.    4. nerf bullets TOBY
```

Are there performance issues here?
