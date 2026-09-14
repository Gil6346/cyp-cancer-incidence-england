-- SQL Queries used

-- Q1 Age profile and cancer type composition
-- Q1a: Total CYP cancer cases by NDRS main cancer types, across all years and age groups.
SELECT
  "NDRS main",
  SUM("Count") AS total_cases
FROM national_incidence
GROUP BY
  "NDRS main"
ORDER BY
  total_cases DESC;

-- Q1b: Case distribution by age group with proportion of total
SELECT
  "Age at diagnosis",
  SUM("Count") AS total_cases,
  ROUND(
    100.0 * SUM("Count") /
	  SUM(SUM("Count")) OVER (),
	  1
  ) AS pct_of_total
FROM national_incidence
GROUP BY
  "Age at diagnosis"
ORDER BY
  total_cases DESC;

-- Q1c: Top 3 cancer types within each age group
WITH ranked_cancers AS (
	SELECT
		"Age at diagnosis",
		"NDRS main",
		SUM("Count") AS total_cases,
		RANK() OVER(
			PARTITION BY "Age at diagnosis"
			ORDER BY SUM("Count") DESC
		) as rank
	FROM national_incidence
	GROUP BY "Age at diagnosis", "NDRS main"
)
SELECT *
FROM ranked_cancers
WHERE rank <= 3
ORDER BY "Age at diagnosis", rank;

-- Q2 Geographic variation across England NHS regions
-- Q2a: Total cases by NHS region, ranked
SELECT
	"Geography name",
	SUM("Count") AS total_cases,
	RANK() OVER(
		ORDER BY SUM("Count") DESC
	) AS regional_rank
FROM regional_incidence
GROUP BY "Geography name"
ORDER BY regional_rank;

-- Q2b: Regional variation by cancer type with burden classification
SELECT
	"Geography name",
	"NDRS main",
	SUM("Count") AS total_cases,
	RANK() OVER(
		PARTITION BY "Geography name"
		ORDER BY SUM("Count") DESC
	) AS regional_rank,
	CASE
		WHEN SUM("Count") >= 500 THEN 'High burden'
		WHEN SUM("Count") >= 200 THEN 'Medium burden'
		ELSE 'Low burden'
	END AS burden_category
FROM regional_incidence
GROUP BY "Geography name", "NDRS main"
ORDER BY "Geography name", regional_rank;

-- Q2c: Population-adjusted regional CYP cancer incidence rates
-- Source: ICD-10 regional dataset (C00-C97 excl. C44, age-specific rate per 100,000, 0-24)
-- Note: not directly comparable with NDRS cancer group findings in Q2a/Q2b
SELECT
	"Geography name",
	ROUND(AVG("Rate (numeric)"), 1) AS avg_rate_per_100k,
	ROUND(MIN("Rate (numeric)"), 1) AS min_rate,
	ROUND(MAX("Rate (numeric)"), 1) AS max_rate,
	RANK() OVER(
		ORDER BY AVG("Rate (numeric)") DESC
	) AS rate_rank
FROM icd10_regional_rates
WHERE
	"Rate (numeric)" IS NOT NULL
GROUP BY
	"Geography name"
ORDER BY
	rate_rank;

-- Q2d: Comparison of raw count rank vs population-adjusted rate rank
WITH count_ranks AS (
	SELECT
		"Geography name",
		SUM("Count") AS total_cases,
		RANK() OVER(
			ORDER BY SUM("Count") DESC
		) AS count_rank
	FROM regional_incidence
	GROUP BY "Geography name"
), 
rate_ranks AS (
	SELECT
		"Geography name",
		ROUND(AVG("Rate (numeric)"), 1) AS avg_rate_per_100k,
		RANK() OVER(
			ORDER BY ROUND(AVG("Rate (numeric)"), 1) DESC
		) AS rate_rank
	FROM icd10_regional_rates
	GROUP BY "Geography name"
)
SELECT
	c."Geography name",
	c.total_cases,
	c.count_rank,
	r.avg_rate_per_100k,
	r.rate_rank,
	c.count_rank - r.rate_rank AS rank_difference
FROM count_ranks AS c
LEFT JOIN rate_ranks AS r
	ON c."Geography name" = r."Geography name"
ORDER BY ABS(c.count_rank - r.rate_rank) DESC;

-- Q3 Yearly trend between 2013 and 2022
-- Q3a: Year-over-year change in national case count
WITH yearly_totals AS (
	SELECT
		"Year",
		SUM("Count") AS total_cases
	FROM national_incidence
	GROUP BY "Year"
)
SELECT
	"Year",
	total_cases,
	LAG(total_cases) OVER (ORDER BY "Year") AS prev_year_cases,
	total_cases - LAG(total_cases) OVER (ORDER BY "Year") AS yoy_diff,
	ROUND(
		100.0 * (total_cases - LAG(total_cases) OVER (ORDER BY "Year"))
		/ LAG(total_cases) OVER (ORDER BY "Year"),
		1
		) AS yoy_pct_change
FROM yearly_totals
ORDER BY "Year";

-- Q3b: Trend by cancer type - first year vs last year comparison
SELECT
	"NDRS main",
	SUM(CASE WHEN "Year" = 2013 THEN "Count" ELSE 0 END) AS cases_2013,
	SUM(CASE WHEN "Year" = 2022 THEN "Count" ELSE 0 END) AS cases_2022,
	SUM(CASE WHEN "Year" = 2022 THEN "Count" ELSE 0 END) - 
	SUM(CASE WHEN "Year" = 2013 THEN "Count" ELSE 0 END) AS absolute_change
FROM national_incidence
GROUP BY "NDRS main"
ORDER BY absolute_change DESC;

-- Q3c: Regional trend - rank each region by cases in first and last year
WITH period_totals AS (
	SELECT
		"Geography name",
		SUM(CASE WHEN "Year" = 2013 THEN "Count" ELSE 0 END) AS cases_2013,
		SUM(CASE WHEN "Year" = 2022 THEN "Count" ELSE 0 END) AS cases_2022
	FROM regional_incidence
	GROUP BY "Geography name"
)
SELECT
	"Geography name",
	cases_2013,
	cases_2022,
	RANK() OVER (ORDER BY cases_2013 DESC) AS rank_2013,
	RANK() OVER (ORDER BY cases_2022 DESC) AS rank_2022
FROM period_totals
ORDER BY rank_2022;
-- Trend comparison uses raw case counts rather than population-adjusted rates. Regional population changes over the 2013–2022 period are relatively modest and unlikely to substantially alter rank-based comparisons, but absolute case count changes should be interpreted alongside the population-adjusted rates presented in Q2c.