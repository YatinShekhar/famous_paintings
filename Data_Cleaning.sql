-- artist table

set sql_safe_updates = 0;

update artist
set middle_names = 'unknown' where middle_names = '';

alter table artist
rename column midlle_name to middle_name;

-- image_link table

-- Finding duplicate rows
select work_id, count(*) from image_link
group by work_id
having count(*) > 1;

-- Delete duplicate rows

alter table image_link
add column row_num int primary key auto_increment;

with cte as (
select row_num, row_number() over(partition by work_id order by row_num) as rn
from image_link)
delete from image_link where row_num not in (select row_num from cte where rn = 1);

alter table image_link
drop column row_num;

-- Their's a '\r' character at the end of each row. Therefore removing the character from each row
 
update image_link
set thumbnail_large_url = replace(thumbnail_large_url, '\r', '');

-- canvas_size table

update canvas_size
set height = null where label like '%Long%';

alter table canvas_size
modify column height tinyint;

update canvas_size
set label = replace(label, '\r', '');

-- museum table

update museum
set city = null where city = '';

update museum 
set state = null where state = '';

update museum 
set postal = null where postal = '';

update museum
set url = replace(url, '\r', '');

-- museum_hours table

-- Finding duplicate rows

select museum_id, day, open, close 
from museum_hours
group by 1,2,3,4
having count(*) > 1;

-- Delete duplicate rows

alter table museum_hours
add column row_num int primary key auto_increment;

with cte as (
select row_num, row_number() over(partition by museum_id, day, open, close order by row_num) as rn
from museum_hours)
delete from museum_hours where row_num not in (select row_num from cte where rn = 1);

alter table museum_hours
drop column row_num;

update museum_hours
set day = 'Thursday' where day = 'Thusday';

-- Changing the datatype of the open and close column which contains time

alter table museum_hours
add column open_new time;

update museum_hours
set open_new = str_to_date(open, '%h:%i:%p');

alter table museum_hours
drop column open;

alter table museum_hours
rename column open_new to open;

alter table museum_hours
add column close_new time;

update museum_hours
set close_new = str_to_date(close, '%h:%i:%p');

alter table museum_hours
drop column close;

alter table museum_hours
rename column close_new to close;

-- product_size table

-- finding duplicates

select work_id, size_id, sale_price, regular_price
from product_size
group by 1,2,3,4
having count(*) > 1;

-- delete duplicates

alter table product_size
add column row_num int primary key auto_increment;

with cte as (
select row_num , row_number() over(partition by work_id, size_id, sale_price, regular_price order by row_num) as rn
from product_size)
delete from product_size where row_num not in ( select row_num from cte where rn = 1);

alter table product_size
drop column row_num;

-- subject table

-- finding duplicate

select work_id, subject, count(*) from subject
group by 1, 2
having count(*) > 1;

-- delete duplicate

alter table subject
add column row_num int primary key auto_increment;

with cte as (
select row_num , row_number() over(partition by work_id, subject order by row_num) as rn
from subject)
delete from subject where row_num not in ( select row_num from cte where rn = 1);

alter table subject
drop column row_num;

update subject
set subject = replace(subject, '\r', '');

-- work table

-- finding duplicate

select work_id, name, artist_id, style, museum_id, count(*) 
from work
group by 1,2,3,4,5
having count(*) > 1;

-- delete duplicate

alter table work
add column row_num int auto_increment primary key;

delete from work 
where row_num not in 
(with cte as 
(select * , row_number() over(partition by work_id, name , artist_id, style, museum_id) as rn 
from work)
select row_num
from cte
where rn = 1);

alter table work
drop column row_num;

update work
set museum_id =  replace(museum_id, '\r', '');

update work
set museum_id = null where museum_id = '';

alter table work
modify column museum_id int;



