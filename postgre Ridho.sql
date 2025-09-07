-- Exercise 1
--Display title and description
--from film table
--that does not contain missing data
--where the first letter is “D” in the track name
--or the last letter is ‘g’ in the composer 
--and sorted alphabetically by composer name

select
title,
description
from
film
where
description is not null and title is not null
and
(
title like 'D%'
or
title like '%g'
)
order by title desc
;

-- Exercise 2
--Display all customer id, number of rental transactions, rental_amount, and rental_amount_average
--in February
--for customers who have rental_amount_average greater than 5
--in the payment table

select
customer_id,
count(customer_id) as number_of_rental_transaction,
sum(amount) as rental_amount,
avg(amount) as rental_amount_average
from
payment
where
date(payment_date) between '2007-02-01' and '2007-02-28'
group by 1
having
avg(amount) > 5
;


-- Exercise 3
--Display all movie titles, length of movie, and additional 1 column with conditions
--from film table
--
--The conditions for movie length are:
--0 – 50		: Short
--51 – 120	: Medium
--Above 120	: Long
select
title,
length,
case 
	when length >= 0 and length <= 50 then 'Short'
	when length <= 120 then 'Medium'
	else 'Long'
end as category_movie_lenght
from
film
;


--Find all film titles with category = ‘Horror’
select
f.title as film_titles
from
film as f
left join category as c on f.film_id = c.category_id 
where
c.name = 'Horror'
;



