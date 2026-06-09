--Приклад коду для синхронізації через SQL View для Power BI--
CREATE OR REPLACE VIEW sync_pbi_script_3_set_delta AS
select 
    to_char(
        CASE 
            WHEN ps."Date"  LIKE '%.%' THEN to_date(ps."Date" , 'DD.MM.YY')
            WHEN ps."Date"  LIKE '%-%' THEN to_date(ps."Date" , 'MM-DD-YY')
            ELSE NULL 
        END, 
        'MM.YYYY'
    ) AS "Date",
	ps."Category" as  "Category",
	sum(ps."Amount") as "Total",
	sum(ps."Amount" - (pc.production_cost + pc.delivery_cost )) as "Profit"
from product_sales ps 
inner join product_cost pc
	on ps."Category" = pc.category  
where ps."Status" in ('Shipped - Delivered to Buyer', 'Shipped')
	and ps."Amount" is not null 
	and ps."Category" like 'Set'
group by ps."Category","Date"
order by "Date" asc ;

