
select * from swiggy_cleaned

select 
	sum( case when hotel_name = '' then 1 else 0 end ) as 'hotel_name', 
	sum( case when rating = '' then 1 else 0 end ) as 'rating',
    sum( case when time_minutes = '' then 1 else 0 end ) as 'time_minutes',
    sum( case when food_type = '' then 1 else 0 end ) as 'food_type',
    sum( case when location = '' then 1 else 0 end ) as 'location',
    sum( case when offer_above = '' then 1 else 0 end ) as 'offer_above',
    sum( case when offer_percentage = '' then 1 else 0 end ) as 'offer_percentage'
    from swiggy_cleaned

-- concat function joins two strings     
select concat('Meet',' Gupta') as Name

-- information_schema.columns is used to check the metadata of table
select * from information_schema.columns where table_name = 'swiggy_cleaned'

select COLUMN_NAME from information_schema.columns where table_name = 'swiggy_cleaned'

-- group concat : it concats output of concat function

-- sum( case when hotel_name = '' then 1 else 0 end ) as 'hotel_name',


delimiter //
create procedure  count_blank_rows()
begin
		select group_concat(
			   concat('sum(case when`', column_name, '`='''' Then 1 else 0 end) as `', column_name ,'`')
			) into @sql 
			from information_schema.columns  where table_name= 'swiggy_cleaned';

		set @sql = concat('select ', @sql,' from swiggy_cleaned');


		prepare smt from  @sql;
		execute  smt ;
		deallocate  prepare smt;
	end
//
delimiter ;

call count_blank_rows()
--                                                           Cleaning time_minutes column


-- shifting values of rating to time_minutes

create table clean as
select * from swiggy_cleaned where rating like '%mins%'

create table cleaned as 
select *, f_name(rating) as 'rat'  from clean 

set sql_safe_updates= 0

 update swiggy_cleaned as s
 inner join cleaned as c 
 on s.hotel_name= c.hotel_name
 set s.time_minutes= c.rat


select * from swiggy_cleaned

drop table cleaned 
drop table clean

-- clening for ('-') from time_minutes

create table clean as
select * from swiggy_cleaned where time_minutes like '%-%'
select * from clean

create table cleaned as 
select *, f_name(time_minutes) as f1, l_name(time_minutes) as f2 from clean

 update swiggy_cleaned as s
 inner join cleaned as c 
 on s.hotel_name= c.hotel_name
 set s.time_minutes =((c.f1+c.f2)/2)
 
 select * from swiggy_cleaned
 
 drop table clean,cleaned
 
 --                                                  time_minutes column is cleaned
 
 --                                                 Cleaning rating column
 
 select * from swiggy_cleaned
 
 select location, round(avg(rating),2) as "avg_rating" from swiggy_cleaned where rating not like '%mins%' group by location
 
 
update swiggy_cleaned as s join (
select location, round(avg(rating),2) as "avg_rating" from swiggy_cleaned where rating not like '%mins%' group by location
 ) as t on s.location = t.location 
set s.rating = t.avg_rating where s.rating like '%mins%'

select * from swiggy_cleaned where rating like'%mins%'

set @rat = (select round(avg(rating),2) as "average" from swiggy_cleaned where rating  not like '%mins%');

update swiggy_cleaned 
set rating = @rat
where rating like '%mins%'

select * from swiggy_cleaned

--                                               Rating column is also cleaned

--                                               Cleaning location column

-- cleaning all east side loaction of each place

select distinct(location) from swiggy_cleaned  where  location like '%East%'

update swiggy_cleaned 
set location  ='Kandivali East'
where location like '%Kandivali (East)%' or location like '%Kandivali east%' or location like '%Kandivali, Malad East%'
or location like '%Kandivali borivali East%' or location like '%Thakur Village%' 

update swiggy_cleaned 
set location  ='Jog Gor East'
where location like '%Mum_Jog Gor East%' or location like '%Jog Gor East%' or location like '%Gor East%'

update swiggy_cleaned 
set location  ='Malad East'
where location like '%Malad Kan East%'

update swiggy_cleaned 
set location  ='Goregaon East'
where location like '%VIthbhati, Goregoan (East) 3)%'

update swiggy_cleaned 
set location  ='Dahisar East'
where location like '%Dahisar East%'

-- cleaning west side location of each place 

select distinct(location) from swiggy_cleaned  where  location like '%West%'

update swiggy_cleaned 
set location  ='Kandivali West'
where location like '%Kandivali (West)%' or location like '%Kandivali - West%' or location like '%Kandivali West%' 
or location like '%Kandivali W%'

update swiggy_cleaned 
set location  ='Malad West'
where location like '%Malad West%' or location like '%malad west%' or location like '%Malad Kan West%'

update swiggy_cleaned 
set location  ='Dahisar West'
where location like '%Dahisar West%'

update swiggy_cleaned 
set location  ='Borivali West'
where location like '%borivali west%' 

update swiggy_cleaned 
set location  ='Goregaon West'
where location like '%Goregaon West%' 

   --                                              location column is cleaned.

 --                                                Cleaning offer_percentage column
 
select * from swiggy_cleaned

update swiggy_cleaned
set offer_percentage = 0
where offer_above = 'not_available'

--                                                  Offer_percentage column is cleaned

--                                                   Cleaning food_type

select distinct food from (
select *, substring_index( substring_index(food_type ,',',numbers.n),',', -1) as 'food'
from  swiggy_cleaned 
	join
	(
		select 1+a.N + b.N*10 as n from 
		(
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
	)  as numbers 
    on  char_length(food_type)  - char_length(replace(food_type ,',','')) >= numbers.n-1
    ) as food_type_subquery
    
    --                                                   Food_type column is cleaned