-- artist table

create table artist(
artist_id	smallint ,
full_name	varchar(100) ,
first_name	varchar(50) ,
middle_names	varchar(50) ,
last_name	varchar(50) ,
nationality	varchar(30) ,
style	varchar(50) ,
birth	smallint , 
death smallint );

load data infile "F://artist.csv"
into table artist
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- image_link table

create table image_link ( 
work_id mediumint ,
url text(500) ,
thumbnail_small_url text(500) ,
thumbnail_large_url text(500));

load data infile "F://image_link.csv"
into table image_link
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- canvas_size table

create table canvas_size (
size_id	mediumint ,
width	tinyint ,
height	varchar(10) ,
label varchar(200));

load data infile "F://canvas_size.csv"
into table canvas_size
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- museum table

create table museum (
museum_id	tinyint,
`name`	varchar(200) ,
address	varchar(200) ,
city	varchar(200),
state varchar(200),
postal varchar(200),
country	varchar(200),
phone	varchar(200),
url  varchar(500)) ;

load data infile "F://museum.csv"
into table museum
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- museum_hours table

create table museum_hours (
museum_id int ,
`day` varchar(20) ,
`open` varchar(20) ,
`close` varchar(20) );

load data infile "F://museum_hours.csv"
into table museum_hours
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- product_size table

create table product_size (
work_id int ,
size_id mediumint ,
sale_price mediumint ,
regular_price mediumint );

load data infile "F://product_size.csv"
into table product_size
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- subject table

create table subject (
work_id	int ,
`subject` varchar(200) );

load data infile "F://subject.csv"
into table subject
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- work table

create table work (
work_id	int ,
`name`	tinytext ,
artist_id	int ,
style	varchar(50) ,
museum_id varchar(50) );

load data infile "F://work.csv"
into table work
fields terminated by ","
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

