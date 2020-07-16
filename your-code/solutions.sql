USE PUBLICATIONS;

-- CHALLENGE 1: TOP 3 MOST PROFITING AUTHORS through derived tables

-- Step 1: Calculate the royalty of each sale for each author

SELECT
	au_id,
    SUM(total_roy + advance) AS total_profit_author
FROM
    (SELECT 
    title_id,
    au_id,
    SUM(sales_royalty) AS total_roy,
    ROUND(AVG(advance)) AS advance -- mysql allows non-aggregated, non-grouped fields, but other sql dbms don't!
FROM
	(SELECT 
    t.title_id,
    ta.au_id,
    ROUND((t.advance * ta.royaltyper / 100), 2) AS advance,
    ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),
            2) AS sales_royalty
	FROM
		sales s
			LEFT JOIN
		titles t ON s.title_id = t.title_id
			LEFT JOIN
		titleauthor ta ON t.title_id = ta.title_id) AS royalties_per_sale
GROUP BY 
	title_id , au_id)
AS roy_adv_per_title_author
GROUP BY au_id
ORDER BY total_profit_author DESC 
LIMIT 3;





-- CHALLENGE 2: TOP 3 MOST PROFITING AUTHORS through temporary tables

-- Step 1: Calculate the royalty of each sale for each author
--  and the advance for each author and publication
DROP TABLE royalties_per_sale;
CREATE TEMPORARY TABLE royalties_per_sale
SELECT 
    t.title_id,
    ta.au_id,
    ROUND((t.advance * ta.royaltyper / 100), 2) AS advance,
    ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),
            2) AS sales_royalty
FROM
    sales s
        LEFT JOIN
    titles t ON s.title_id = t.title_id
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id;

-- Step 2: Aggregate the total royalties for each title and author
DROP TABLE roy_adv_per_title_author;
CREATE TEMPORARY TABLE roy_adv_per_title_author
SELECT 
    title_id,
    au_id,
    SUM(sales_royalty) AS total_roy,
    ROUND(AVG(advance)) AS advance -- mysql allows non-aggregated, non-grouped fields, but other sql dbms don't!
FROM
	royalties_per_sale
GROUP BY 
	title_id , au_id;

SELECT * from roy_adv_per_title_author;

-- Step 3: Calculate the total profits of each author
SELECT
	au_id,
    SUM(total_roy + advance) AS total_profit_author
FROM
    roy_adv_per_title_author
GROUP BY au_id
ORDER BY total_profit_author DESC 
LIMIT 3;


-- CHALLENGE 3: TOP MOST PROFITING AUTHORS through temporary tables


DROP TABLE most_profiting_authors;
CREATE TABLE most_profiting_authors
AS
(SELECT
	au_id,
    SUM(total_roy + advance) AS total_profit_author
FROM
    (SELECT 
    title_id,
    au_id,
    SUM(sales_royalty) AS total_roy,
    ROUND(AVG(advance)) AS advance -- mysql allows non-aggregated, non-grouped fields, but other sql dbms don't!
FROM
	(SELECT 
    t.title_id,
    ta.au_id,
    ROUND((t.advance * ta.royaltyper / 100), 2) AS advance,
    ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),
            2) AS sales_royalty
	FROM
		sales s
			LEFT JOIN
		titles t ON s.title_id = t.title_id
			LEFT JOIN
		titleauthor ta ON t.title_id = ta.title_id) AS royalties_per_sale
GROUP BY 
	title_id , au_id)
AS roy_adv_per_title_author
GROUP BY au_id
ORDER BY total_profit_author DESC);

SELECT * FROM most_profiting_authors;

