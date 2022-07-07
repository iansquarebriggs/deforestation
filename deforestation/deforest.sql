/* Table 1 */
SELECT t1.forest_area_sqkm, year, country_name
FROM (
    SELECT forest_area_sqkm, year, country_name
    FROM forest_area
    WHERE year = 1990 OR year = 2016) t1
WHERE country_name = 'World';

/* Table 1 */
SELECT MAX(t2.forest_area_sqkm) - MIN(t2.forest_area_sqkm) AS loss,
(MAX(t2.forest_area_sqkm) - MIN(t2.forest_area_sqkm)) / MAX(t2.forest_area_sqkm) * 100 AS percent_change
FROM (
    SELECT t1.forest_area_sqkm, t1.year, t1.country_name
    FROM (
        SELECT forest_area_sqkm, year, country_name
        FROM forest_area
        WHERE year = 1990 OR year = 2016) t1
    WHERE country_name = 'World') t2;

/* Table 1 */
SELECT year, (total_area_sq_mi * 2.59) AS sqkm, country_name
FROM land_area
WHERE year = '2016'
ORDER BY 2;

/* Table 2.1 */
CREATE VIEW deforestation AS
SELECT r.region,
       fa.year,
       (SUM(fa.forest_area_sqkm) / SUM(la.total_area_sq_mi * 2.59)) * 100 AS percent
FROM forest_area fa
JOIN land_area la
ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r
ON la.country_code = r.country_code
WHERE fa.year = '2016' OR fa.year = '1990'
GROUP BY 1, 2
ORDER BY 3;

/* Table 3.1 */
WITH t1 AS (
SELECT country_name, year, forest_area_sqkm
FROM forest_area
WHERE year = '2016'),
t2 AS (
SELECT country_name AS country_name_two, year AS year_two,
forest_area_sqkm AS forest_two
FROM forest_area
WHERE year = '1990'),
t3 AS (
SELECT region, country_name AS country_name_three FROM regions)
SELECT region, country_name, COALESCE(forest_area_sqkm - forest_two, 0) AS absolute_forest_area_change
FROM t1
JOIN t2
ON t1.country_name = t2.country_name_two
JOIN t3
ON t2.country_name_two = t3.country_name_three WHERE country_name NOT LIKE 'World'
ORDER BY 3
LIMIT 3;

 /* Table 3.2 */
SELECT t4.country_name, t4.region, (t4.difference / (t4.forest_two + 0.01)) * 100 AS percent FROM
(WITH t1 AS (
SELECT country_name,
year,
forest_area_sqkm FROM forest_area
WHERE year = '2016'),
t2 AS (
SELECT country_name AS country_name_two,
year AS year_two,
forest_area_sqkm AS forest_two FROM forest_area
WHERE year = '1990'),
t3 AS (
SELECT region,
country_name AS country_name_three FROM regions)
SELECT region, country_name,
year,
COALESCE(forest_area_sqkm, 0) AS forest_area_sqkm, year_two,
COALESCE(forest_two, 0) AS forest_two, COALESCE(forest_area_sqkm - forest_two, 0) AS difference
FROM t1
JOIN t2
ON t1.country_name = t2.country_name_two
JOIN t3
ON t2.country_name_two = t3.country_name_three ORDER BY difference) AS t4
ORDER BY 3
LIMIT 3;

 /* Table 3.3 */
SELECT t3.quartile, COUNT(*)
FROM (
    SELECT t2.country_name,
    t2.region_name,
    t2.percent,
    CASE WHEN (t2.percent > 75) THEN '4'
    WHEN t2.percent <= 75 AND t2.percent > 50 THEN '3' WHEN t2.percent <= 50 AND t2.percent > 25 THEN '2' ELSE '1' END AS quartile
    FROM (
        SELECT COALESCE(t1.forest_pct, 0) AS percent,
        t1.country AS country_name, t1.region AS region_name
            FROM (
                SELECT f.year,
                       (SUM(f.forest_area_sqkm) / (SUM(l.total_area_sq_mi) * 2.59)) * 100 AS forest_pct,
                       f.country_name AS country,
                       r.region AS region
                       FROM forest_area f
                       JOIN land_area l
                       ON f.country_code = l.country_code JOIN regions r
                       ON l.country_code = r.country_code
                       WHERE f.year = '2016'
                       GROUP BY 1, 3, 4) AS t1
           GROUP BY t1.forest_pct, t1.country, t1.region) AS t2
    ORDER BY 4, 3) AS t3

/* Table 3.4 */
SELECT t2.country_name,
t2.region_name,
t2.percent FROM (
SELECT COALESCE(t1.forest_pct, 0) AS percent, t1.country AS country_name, t1.region AS region_name FROM (
SELECT f.year,
(SUM(f.forest_area_sqkm) / (SUM(l.total_area_sq_mi) * 2.59)) * 100 AS forest_pct,
f.country_name AS country,
r.region AS region
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code JOIN regions r
ON l.country_code = r.country_code
WHERE f.year = '2016'
GROUP BY 1, 3, 4) AS t1
GROUP BY t1.forest_pct, t1.country, t1.region) AS t2
ORDER BY 3 DESC LIMIT 3;
