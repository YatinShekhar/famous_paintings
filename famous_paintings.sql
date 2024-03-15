-- 1. Fetch all the paintings which are not displayed on any museums?

with cte as (
	select work_id
	from work
	group by work_id
	having count(museum_id) = 0)
select count(work_id) from cte;

-- 2. Are there museums without any paintings?  

select museum_id 
from museum m 
left join 
(select distinct(museum_id) from work) a
using(museum_id)
where m.museum_id is null;

-- 3. How many paintings have an asking price of more than their regular price?  -- 
select count(distinct work_id)
from product_size
where sale_price > regular_price;

-- 4. Identify the paintings whose asking price is less than 50% of its regular price?  

select distinct *
from product_size
where sale_price < regular_price/2;

-- 5. Which canva size costs the most?  

with cte as 
	(select * , dense_rank() over(order by sale_price desc) as rn
	from product_size)
select cs.* 
from cte 
inner join 
canvas_size cs using(size_id) 
where  rn = 1;	

-- 6. Fetch the top 10 most famous painting subject

select  subject, count(*) as total_paintings 
from subject
group by 1
order by 2 desc
limit 10;

-- 7. Identify the museums which are open on both Sunday and Monday. Display museum name, city  

select m.museum_id, name, city
from museum_hours mh 
inner join
museum m using(museum_id)
where day in ('Sunday', 'Monday')
group by museum_id, name, city
having count(*) = 2;

-- 8. How many museums are open every single day?

with cte as 
	(select museum_id
	from museum_hours
	group by museum_id
	having count(distinct day) = 7)
select count(museum_id) 
from cte;

-- 9. Which are the top 5 most popular museum? (Popularity is defined based on most
-- no of paintings in a museum)

select m.museum_id, m.name, m.city, m.country, no_of_paintings
from museum m
inner join 
	(select museum_id , count(work_id) as no_of_paintings
    from work
	group by museum_id) as a
using(museum_id)
order by no_of_paintings desc
limit 5;

-- 10. Who are the top 5 most popular artist? (Popularity is defined based on most no of
-- paintings done by an artist)

select a.artist_id, a.full_name, a.nationality, a.style, paintings
from artist a 
inner join 
	(select artist_id, count(distinct work_id) as paintings 
    from work
	group by artist_id) b
using(artist_id)
order by paintings desc
limit 5;

-- 11. Display the 3 least popular canva sizes

with cte as (
	select c.label, count(*) as no_of_paintings, 
		dense_rank() over (order by count(*)) as rn
	from canvas_size c 
    inner join 
    product_size p using(size_id)
	inner join 
    work w using (work_id)
	group by 1)
select label, no_of_paintings 
from cte 
where rn <=3;

-- 12. Which museum is open for the longest during a day. Dispay museum name, state
-- and hours open and which day?

with cte as 
	(select *, timediff(close, open) as working_hours
	from museum_hours)
, cte2 as 
	(select *, dense_rank() over(partition by day order by working_hours desc) as rn
	from cte)
select name, state, working_hours, day
from cte2 
inner join 
museum using(museum_id)
where rn = 1;

-- 13. Which museum has the most no. of most popular painting style?

with cte as 
	(select style, count(work_id) as total_paintings, 
    dense_rank() over (order by count(work_id) desc) as rn
	from work
	group by style)
select 
	m.museum_id, m.name, m.city, m.country, cte.style, count(*) as paintings_in_museum 
from work 
inner join
museum m using(museum_id) 
inner join 
cte using(style)
where rn = 1 
group by 1,2,3,4,5
order by paintings_in_museum desc
limit 1;

-- 14. Identify the artists whose paintings are displayed in multiple countries 

with cte as 
	(select 
		a.full_name, m.country, count(*) as paintings
	from work
	inner join 
    museum m using(museum_id)
	inner join 
    artist a using(artist_id)
	group by 1,2 )
select 
	full_name, count(distinct country) as countries, sum(paintings) as no_of_paintings
from cte
group by 1
having count(distinct country) > 1
order by no_of_paintings desc;

-- 15. Display the country and the city with most no of museums. Output 2 seperate
-- columns to mention the city and country. If there are multiple value, seperate them
-- with comma.

with cte as
	(select 
	country, rank() over(order by count(*) desc) as rn_1
	from museum
	group by 1
	having country is not null)
, cte2 as
	(select 
	city, rank() over(order by count(*) desc) as rn_2
	from museum
	group by 1
	having city is not null)
select 
	group_concat(distinct country) as counties, group_concat(distinct city) as cities 
from cte
cross join cte2 
where rn_1 = 1 and rn_2 = 1
group by rn_1;

-- 16. Identify the artist and the museum where the most expensive and least expensive
-- painting is placed. Display the artist name, sale_price, painting name, museum
-- name, museum city and canvas label

with cte as 
	(select distinct * 
    from product_size
	where 
		sale_price = (select min(sale_price) from product_size)
	union all
	select distinct * 
    from product_size
	where 
		sale_price = (select max(sale_price) from product_size))
select 
	a.artist_id, a.full_name as artist_name, cte.sale_price, w.name as painting_name, 
    m.name as museum_name,m.city, c.label 
from cte 
left join 
work w using(work_id)
left join 
museum m using(museum_id)
left join 
artist a using(artist_id)
left join 
canvas_size c using(size_id);

-- 17. Which country has the 5th highest no of paintings?

select 
	country, count(distinct work_id) as paintings 
from work 
inner join 
museum using(museum_id)
group by 1
order by 2 desc
limit 4,1;

-- 18. Which are the 3 most popular and 3 least popular painting styles?

(select style, count(work_id) as paintings 
from work
group by 1
order by 2 desc 
limit 3)
	union all
(select style, count(work_id) as paintings 
from work
group by 1
order by 2  
limit 3);

-- 19. Which artist has the most no of Portraits paintings outside USA?. Display artist
-- name, no of paintings and the artist nationality

with cte as (
	select 
		a.full_name, a.nationality, count(*) as no_of_paintings, rank() over(order by count(*) desc) as rn
	from work w
	inner join 
    museum m using(museum_id)
	inner join 
    artist a using(artist_id)
	inner join 
    subject s using(work_id)
	where country != 'USA' and subject = 'Portraits'
	group by 1, 2)
select * 
from cte 
where rn = 1