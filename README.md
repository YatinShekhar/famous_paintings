# Famous Paintings

## Project Overview

The analysis can be done on various aspects and insights can be found such as artist demographics, artwork characteristics, pricing trends, museum locations, and subject matter. These insights can also inform decisions related to curation, marketing, and investment in the art world, helping stakeholders better understand and leverage the dynamics of artistic creation, exhibition, and consumption.

## Data Cleaning
It is our priority to transform and structure the data with the intent of improving data quality and making it more consumable and useful for analytics. I have used various commands like alter, update, modify to clean the table and delete duplicate rows from the desired tables.

### Method for deleting duplicates

``` sql
alter table table_name
add column row_num int primary key auto_increment;

with cte as (
select row_num, row_number() over(partition by column_name order by row_num) as rn
from table_name)
delete from table_name where row_num not in (select row_num from cte where rn = 1);

alter table table_name
drop column row_num
```

## Analysis Approach

The follwing questions can be considered as key insights on the basis of which stakeholders in the art industry can make informed decisions to enhance audience engagement, optimize resource allocation, and drive sustainable growth and success.
- Fetch all the paintings which are not displayed on any museums?
- Are there museuems without any paintings?
- How many paintings have an asking price of more than their regular price? 
- Identify the paintings whose asking price is less than 50% of its regular price
- Which canva size costs the most?
- Fetch the top 10 most famous painting subject
- How many museums are open every single day?
- Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
- Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
- Which museum has the most no of most popular painting style?
- Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
- Which country has the 5th highest no of paintings?
- Which are the 3 most popular and 3 least popular painting styles?
- Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

## SQL SCRIPT FOR COMPLEX QUESTIONS:

1. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
``` sql
select m.museum_id, name, city
from museum_hours mh 
inner join
museum m using(museum_id)
where day in ('Sunday', 'Monday')
group by museum_id, name, city
having count(*) = 2;
```

2. Display the 3 least popular canva sizes
``` sql
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
```

3. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
``` sql
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
```

4. Which museum has the most no of most popular painting style?
``` sql
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
```

5. Identify the artists whose paintings are displayed in multiple countries
``` sql
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
```

6. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
``` sql
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
```
