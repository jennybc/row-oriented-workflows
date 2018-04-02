#' ---
#' title: "Why nesting is worth the awkwardness"
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
library(gapminder)
library(tidyverse)

# ----
#' gapminder data for Asia only
gap <- gapminder %>%
  filter(continent == "Asia") %>%
  mutate(yr1952 = year - 1952)

ggplot(gap, aes(x = lifeExp, y = country)) +
  geom_point()
#' Random arrangement of countries
#'
#' Set factor levels with intent. Imagine you want this to persist across an
#' entire analysis.
gap <- gap %>%
  mutate(country = fct_reorder2(country, x = -1 * year, y = lifeExp))

ggplot(gap, aes(x = lifeExp, y = country)) +
  geom_point()

#' Much better!
#'
#' Now imagine we want to fit a model to each country and lot at dot plots of
#' slope and intercept.
#'
#' Nested approach ... leaves `country` as factor.
gap_nested <- gap %>%
  group_by(country) %>%
  nest()

gap_fitted <- gap_nested %>%
  mutate(fit = map(data, ~ lm(lifeExp ~ yr1952, data = .x)))

gap_fitted <- gap_fitted %>%
  mutate(
    intercept = map_dbl(fit, ~ coef(.x)[["(Intercept)"]]),
    slope = map_dbl(fit, ~ coef(.x)[["yr1952"]])
  )

ggplot(gap_fitted, aes(x = intercept, y = country)) +
  geom_point()

ggplot(gap_fitted, aes(x = slope, y = country)) +
  geom_point()

#' The `split()` + `lapply()` + `do.call(rbind, ...)` approach
#' Much fussing
gap_split <- split(gap, gap$country)
gap_split_fits <- lapply(
  gap_split,
  function(df) {
    lm(lifeExp ~ yr1952, data = df)
  }
)
## oops ... the unused levels of country are a problem

gap_split <- split(droplevels(gap), droplevels(gap)$country)
gap_split_coefs <- lapply(
  gap_split,
  function(df) {
    coef(lm(lifeExp ~ yr1952, data = df))
  }
)
gap_split_coefs <- as.data.frame(do.call(rbind, gap_split_coefs))
gap_split_coefs$country <- rownames(gap_split_coefs)
str(gap_split_coefs)

ggplot(gap_split_coefs, aes(x = `(Intercept)`, y = country)) +
  geom_point()

ggplot(gap_split_coefs, aes(x = yr1952, y = country)) +
  geom_point()
#' We are back to the random order of countries.












gap <- gapminder %>%
  filter(year %in% c(1952, 2007), continent != "Oceania") %>%
  droplevels() %>%
  select(continent, year, lifeExp) %>%
  mutate(continent = fct_reorder2(continent, x = year, y = lifeExp)) %>%
  arrange(continent, year)
View(gap)

levels(gap$continent)

ggplot(gap, aes(x = year, y = lifeExp, color = continent)) +
  geom_jitter(width = 10) + geom_smooth(method = "lm", se = FALSE)

gap_nested <- gap %>%
  group_by(continent) %>%
  nest()
gap_nested

gap_nested$data[[1]]
t.test(lifeExp ~ year, data = gap_nested$data[[1]])

gap_tested <- gap_nested %>%
  mutate(tt = map(data, ~ t.test(lifeExp ~ year, data = .x)))

gap_tested$tt[[1]]
gap_tested$tt[[1]][["statistic"]]

gap_tested <- gap_nested %>%
  mutate(tt = map(data, ~ t.test(lifeExp ~ year, data = .x)),
         tt = map_dbl(tt, "statistic"))
gap_tested

gap_split <- split(gap, gap$continent)
gap_split_tested <- lapply(
  gap_split,
  function(df) t.test(lifeExp ~ year, data = df)
)
gap_split_tested <- lapply(gap_split_tested, `[[`, "statistic")




gap <- gapminder %>%
  mutate(country = fct_reorder2(country, x = year, y = lifeExp)) %>%
  arrange(country, year)
View(filter(gap, year == 2007))


gap <- gapminder %>%
  filter(country %in% c("Japan", "China", "Pakistan", "Afghanistan")) %>%
  droplevels()

ggplot(gap, aes(x = year, y = lifeExp, color = country)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)


gap <- gapminder %>%
  filter(country %in% c("Japan", "China", "Pakistan", "Afghanistan")) %>%
  droplevels() %>%
  mutate(
    country = fct_reorder2(country, x = year, y = lifeExp),
    yr1952 = year - 1952
  )

ggplot(gap, aes(x = year, y = lifeExp, color = country)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

levels(gap$country)

#' Much better! Now we do more analyses, that require split-apply-combine.

gap_nested <- gap %>%
  group_by(country) %>%
  nest()

gap_fitted <- gap_nested %>%
  mutate(fit = map(data, ~ lm(lifeExp ~ yr1952, data = .x)))

gap_fitted$fit[[1]]

