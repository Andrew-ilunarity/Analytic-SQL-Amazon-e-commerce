--Фактична ціна виробництва проти ціни продажу за весь час і маржа--
select 
	ps."Category" as  "Category",
	sum(pc.delivery_cost::int + pc.production_cost::int ) as "Fact price",
	sum(ps."Amount"::int) as "Total",
	sum(ps."Amount"::int - (pc.production_cost::int + pc.delivery_cost::int )) as "Profit"
from product_sales ps 
inner join product_cost pc
	on ps."Category" = pc.category  
where ps."Amount" is not null 
group by ps."Category"
order by "Profit" desc ;
