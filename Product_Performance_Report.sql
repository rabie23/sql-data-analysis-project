WITH product_base AS (
    SELECT
        product_id,
        product_name,
        category,
        subcategory,
        product_line,
        cost,
        start_date
    FROM [gold.dim_products]
    WHERE category IS NOT NULL
),

product_age AS (
    SELECT
        product_id,
        product_name,
        category,
        subcategory,
        product_line,
        cost,
        start_date,
        DATEDIFF(YEAR, start_date, GETDATE()) AS produkt_alter_jahre
    FROM product_base
),

product_segments AS (
    SELECT
        product_id,
        product_name,
        category,
        subcategory,
        product_line,
        cost,
        produkt_alter_jahre,
        CASE 
            WHEN cost > 1000 THEN 'Premium'
            WHEN cost BETWEEN 300 AND 1000 THEN 'Mid-Range'
            ELSE 'Entry-Level'
        END AS preis_segment,
        CASE
            WHEN produkt_alter_jahre < 3 THEN 'New'
            WHEN produkt_alter_jahre BETWEEN 3 AND 8 THEN 'Established'
            ELSE 'Legacy'
        END AS lifecycle_segment
    FROM product_age
),

category_kpis AS (
    SELECT
        category,
        subcategory,
        COUNT(product_id) AS produkt_anzahl,
        AVG(cost) AS avg_cost,
        MIN(cost) AS min_cost,
        MAX(cost) AS max_cost
    FROM product_base
    GROUP BY category, subcategory
)

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.product_line,
    p.cost,
    p.produkt_alter_jahre,
    p.preis_segment,
    p.lifecycle_segment,
    k.produkt_anzahl,
    k.avg_cost,
    k.min_cost,
    k.max_cost
FROM product_segments p
LEFT JOIN category_kpis k
    ON p.category = k.category
    AND p.subcategory = k.subcategory;










