/*
===============================================================================
Kundenbericht
===============================================================================
Zweck:
    - Dieser Bericht fasst wichtige Kundenkennzahlen und -verhalten zusammen

Highlights:
    1. Erfasst wichtige Felder wie Namen, Alter und Transaktionsdetails.
    2. Segmentiert Kunden in Kategorien (VIP, Stammkunden, Neukunden) und Altersgruppen.
    3. Aggregiert Kennzahlen auf Kundenebene:
       - Gesamtzahl der Bestellungen
       - Gesamtumsatz
       - Gesamtkaufmenge
       - Gesamtzahl der Produkte
       - Lebensdauer (in Monaten)
    4. Berechnet wertvolle KPIs:
        - Aktualität (Monate seit der letzten Bestellung)
        - Durchschnittlicher Bestellwert
        - Durchschnittliche monatliche Ausgaben
===============================================================================
*/
CREATE VIEW [gold.report_customers] AS
WITH base_abfrage as (
--1. Base_query: Erfasst wichtige Felder wie Namen, Alter und Transaktionsdetails.
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name,' ' , c.last_name) as fullname,
-- c.birthdate(-) getdate()
DATEDIFF(year, c.birthdate, getdate()) age
from [gold.fact_sales] f
left join [gold.dim_customers] c 
on f.customer_key = c.customer_key
-- filter
WHERE order_date is not null)

/* 3. Aggregiert Kennzahlen auf Kundenebene:
       - Gesamtzahl der Bestellungen
       - Gesamtumsatz
       - Gesamtkaufmenge
       - Gesamtzahl der Produkte
       - Lebensdauer (in Monaten)*/

, customer_aggregation as(
select
customer_key,
customer_number,
fullname,
age,
count(distinct order_number) as total_order,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count ( distinct product_key) as total_products,
max (order_date) as last_order_date,
datediff(month, min(order_date), max(order_date)) as lifespan
from base_abfrage
group by customer_key,
 customer_number,
 fullname,
 age
 )

 /*2. Segmentiert Kunden in Kategorien (VIP, Stammkunden, Neukunden) und Altersgruppen.*/
select
customer_key,
customer_number,
fullname,
age,
CASE 
WHEN age <20 THEN 'Under 20'
WHEN age between 20 and 29 THEN '20-29'
WHEN age between 30 and 40 THEN '30-40'
WHEN age between 40 and 49 THEN '40-49'
ELSE '50 und älter' END AS age_group,
CASE 
WHEN lifespan>= 12 AND total_sales > 5000 THEN 'VIP'
WHEN lifespan>= 12 AND total_sales < 5000 THEN 'Regular'
ELSE 'New' END AS customer_segment,
/*4. Berechnet wertvolle KPIs:
  (Monate seit der letzten Bestellung)
        - Durchschnittlicher Bestellwert
        - Durchschnittliche monatliche Ausgaben*/
datediff(month, last_order_date, getdate()) as [Seit wann ?],
--- Durchschnittlicher Bestellwert
CASE WHEN total_order = 0 THEN 0 
else  total_sales / total_order end as [AVG bestellwert],
--- Durchschnittliche monatliche Ausgaben*/
CASE WHEN lifespan = 0 THEN 0
else total_sales / lifespan end as [pro monate ausgabe],

total_order,
total_sales,
total_quantity,
total_products,
last_order_date,
lifespan

from customer_aggregation

