select
age_group,
customer_segment,
count (customer_number) as total_kunde,
sum(total_sales) as total_sales
from [gold.report_customers]
group by age_group, customer_segment
