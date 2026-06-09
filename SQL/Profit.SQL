--Об'єднання таблиць,підрахунок маржі по штатам та категоріям,кількість продажів--
select 
	upper(ps."ship-state" ) as "Ship State",
	ps."Category" as  "Category",
	count("Order ID") as "Sales",
	sum(ps."Amount") as "Total",
	sum(ps."Amount" - (pc.production_cost + pc.delivery_cost )) as "Profit"
from product_sales ps 
inner join product_cost pc
	on ps."Category" = pc.category  
where ps."Status" in ('Shipped - Delivered to Buyer', 'Shipped')
	and ps."Amount" is not null 
group by upper(ps."ship-state" ),ps."Category"
order by "Profit" desc ;
