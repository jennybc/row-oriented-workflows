Leave your data in that big, beautiful data frame
================
Jenny Bryan
2018-04-02

## Two code styles

Code style that results from (I speculate) minimizing the number of key
presses.

``` r
## :(
sl <- iris[51:100,1]
pw <- iris[51:100,4]
plot(sl ~ pw)
```

![](ex01_leave-it-in-the-data-frame_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

More verbose code conveys intent. Eliminating the Magic Numbers makes
the code less likely to be, or become, wrong.

``` r
## :) version 1
library(tidyverse)

ggplot(
  filter(iris, Species == "versicolor"),
  aes(x = Petal.Width, y = Sepal.Length)
) + geom_point()
```

![](ex01_leave-it-in-the-data-frame_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r

## :) version 2, using the pipe operator, %>%
iris %>%
  filter(Species == "versicolor") %>%
  ggplot(aes(x = Petal.Width, y = Sepal.Length)) + ## <--- NOTE the `+` sign!!
  geom_point()
```

![](ex01_leave-it-in-the-data-frame_files/figure-gfm/unnamed-chunk-3-2.png)<!-- -->
