How to add or modify a variable
================
Jenny Bryan
2018-04-02

``` r
library(tidyverse)
```

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

## The `df$var <- ...` syntax

This absolutely works. But there are downsides:

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

## `dplyr::mutate()` works “inside the box”

`dplyr::mutate()` is the tidyverse way to work on a variable:

  - Only a length one input can be recycled.
  - `df` is the first place to look for things. It turns out that making
    a new variable out of existing variables is very, very common.
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
