create database zomato;
use zomato;

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid int,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) VALUES (1,'2017-09-22'),(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;



####   ANSWERS   ######





 #   Answer -->1 

select s.userid,sum(p.price) Total_Amount from sales s join product p on s.product_id=p.product_id group by s.userid order by userid;


#   ANSWER -->2

select userid,count(distinct(created_date)) Total_Days from sales group by userid order by userid;


#  ANSWER ----> 3


select * from (select * ,dense_rank() over(partition by userid order by created_date) RN from sales) T where RN=1;

select * from (
select s.userid,s.created_date,p.product_name, dense_rank () over( partition by userid order by created_date) as RN from sales s join product p on s.product_id=p.product_id
) T 
where RN=1;


#  ANSWER ---> 4

# PART - 1
 select product_id , count(userid) as times_order from sales group by product_id;  # --> To see which product id purchased most.
 
 # PART - 2 

select userid,count(userid) as product_count from sales where product_id=
(select product_id from 
(select product_id , count(userid) as times_order from sales group by product_id order by times_order desc) h limit 1) 
group by userid order by userid;
 

# ANSWER - 5  --->

select * from 
(select * ,dense_rank() over (partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk=1;


# ANSWER - 6 --->
select * from
(select *,dense_rank() over (partition by userid order by created_date) rnk from sales order by userid,created_date) t where rnk=1;

# NOTE - Below answer is more accurate as we've taken usesrs doing shopping after they were created only -->

with cte0 as(
with cte as 
(select s.userid,s.created_date,s.product_id from sales s join users u on s.userid=u.userid and s.created_date>=u.signup_date)
select *,dense_rank() over (partition by userid order by created_date) rnk from cte order by s.userid,s.created_date) 
select * from cte0 where rnk=1;


# NOTE ---> If we want to filter the same above data from those who signed up just after they became the gold-member -->
# I have joined product table also to see the particular products also which were bought after customers became gold-member
with cte0 as
(select * from 
(with cte as
(select s.userid,s.created_date,s.product_id from sales s join goldusers_signup g on s.userid=g.userid and s.created_date>=g.gold_signup_date)
select userid,created_date,product_id,dense_rank() over (partition by userid order by created_date) rnk from cte) t 
where rnk=1)
select userid,created_date,product_name from cte0 c join product p on c.product_id=p.product_id;




# ANSWER - 7 ---> Same question as 6, just change the sign of ('>')


with cte0 as(
with cte as 
(select s.userid,s.created_date,s.product_id from sales s join users u on s.userid=u.userid and s.created_date<=u.signup_date)
select *,dense_rank() over (partition by userid order by created_date) rnk from cte order by s.userid,s.created_date) 
select * from cte0 where rnk=1;

# NOTE ---> considering again as above that, buying products just before they became gold-member -->

select * from 
(with cte as
(select s.userid,s.created_date,s.product_id from sales s join goldusers_signup g on s.userid=g.userid and s.created_date<=g.gold_signup_date)
select userid,created_date,product_id,dense_rank() over (partition by userid order by created_date desc) rnk from cte) t 
where rnk=1;

# ANSWER - 8 ---> (what is total orders and amount spent for each member before they become a member?)


select userid,count(created_date) No_of_Orders_Purchased, sum(price) Total_amount_spent from
(select s.userid,s.created_date,g.gold_signup_date,p.product_name,p.price from sales s join goldusers_signup g on s.userid=g.userid and s.created_date<=g.gold_signup_date
join product p on s.product_id=p.product_id) f group by userid order by userid;


# ANSWER - 9 --->

# PART - 1 --->

select userid, sum(total_points) Total_points_earned from 
(select e.*, amt/points total_points from 
(select d.*,case
when product_id=1 then 5
when product_id=2 then 2
when product_id=3 then 5 
else 0 
end as points from
(select userid,product_id,sum(price) amt from (
select s.*,p.price from sales s join product p on s.product_id=p.product_id
) t group by userid,product_id) d ) e) f group by userid;


# PART - 2 --->

select * from
(select *, dense_rank() over (order by Total_points_earned desc) rnk from 
(select product_id, sum(total_points) Total_points_earned from 
(select e.*, amt/points total_points from 
(select d.*,case
when product_id=1 then 5
when product_id=2 then 2
when product_id=3 then 5 
else 0 
end as points from
(select userid,product_id,sum(price) amt from (
select s.*,p.price from sales s join product p on s.product_id=p.product_id
) t group by userid,product_id) d ) e) f group by product_id order by product_id) g ) h where rnk=1; 



# ANSWER - 10 ---->

select a.*, p.price*0.5 Total_points_earned from (
select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s join goldusers_signup g on s.userid=g.userid and s.created_date>=g.gold_signup_date and s.created_date<=adddate(g.gold_signup_date,interval 365 day) ) a join product p on a.product_id=p.product_id;


# ANSWER - 11 ---->

select *, rank() over (partition by userid order by created_date) from sales;


# ANSWER - 12 ---->

select c.*, case when gold_signup_date is null then 'na' else rank() over (partition by userid order by created_date desc) end as rnk from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s 
left join goldusers_signup g on s.userid=g.userid and s.created_date>=g.gold_signup_date) c;