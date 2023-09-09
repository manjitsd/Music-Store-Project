-- Q1 Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

-- Q2 Which country have the most invoices?

select count(invoice_id) as Count_of_Invoices, billing_country as Country_Name from invoice
group by Country_Name
order by Count_of_Invoices desc;

-- Q3 What are the top 3 values of total invoice?

select invoice_id, total from invoice
order by total desc
limit 3;

-- Q4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice  totals?

select billing_city as city_name, sum(total) as invoice_total from invoice
group by city_name
order by invoice_total desc;

-- Q5 Who is the best customer? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money?

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_sum
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.customer_id
order by total_sum desc
limit 1;

-- Q6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A?

select distinct c.email, c.first_name, c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email asc;
-- SECOND METHOD-----------------------
select distinct c.email, c.first_name, c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (
			select track_id from track t
            join genre g on t.genre_id = g.genre_id
            where g.name like 'Rock'
)
order by email;

-- Q7 Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands?

select a.artist_id, a.name, count(a.artist_id) as No_of_Songs
from artist a
join album ab on a.artist_id = ab.artist_id
join track t on ab.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by a.artist_id
order by No_of_Songs desc
limit 10;

-- Q8 Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first?

select name, milliseconds
from track
where milliseconds > (
		select avg(milliseconds) as avg_length 
        from track)
order by milliseconds desc;

-- Q9 Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent?

select c.customer_id, c.first_name, c.last_name, art.name as artist_name,
sum(il.quantity*il.unit_price) as total_spent_by_customer
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join artist art on a.artist_id = art.artist_id
group by c.customer_id, c.first_name, c.last_name, artist_name
order by total_spent_by_customer desc;

-- SECOND METHOD--------------------------------------
-- FOR TOP 1 ARTIST SALES BY CUSTOMER--
with best_selling_artist as(
		select a.artist_id, a.name, sum(il.unit_price*il.quantity) as total_spent
		from invoice_line il
		join track t on il.track_id = t.track_id
		join album al on t.album_id = al.album_id
		join artist a on al.artist_id = a.artist_id
		group by 1
		order by 3 desc
		limit 1)

select c.customer_id, c.first_name, c.last_name, bsa.name as artist_name,
sum(il.quantity*il.unit_price) as total_spent_by_customer
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join artist art on a.artist_id = art.artist_id
join best_selling_artist bsa on bsa.artist_id = art.artist_id
group by 1,2,3,4
order by 5 desc;

-- Q10 We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres?

with country_genre as (
	select c.country, g.name, g.genre_id, count(i.invoice_id) as no_of_purchases,
	row_number() over(partition by c.country order by count(i.invoice_id) desc) as Rowno
	from customer c
	join invoice i on c.customer_id = i.customer_id
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by 1,2,3
	order by 1 asc, 4 desc)
select * from country_genre where Rowno = 1 order by no_of_purchases desc;
-- It can be solved without using the customer table, and taking billing_country from invoice table.

-- Q11 Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount?

with customer_country as (
	select c.customer_id, c.first_name, c.last_name, c.country, sum(i.total) as sum_total,
	row_number() over(partition by c.country order by sum(i.total) desc) as rownum
	from customer c
	join invoice i on c.customer_id = i.customer_id
	group by 1,2,3
	order by 4 asc, 5 desc
)
select * from customer_country where rownum = 1 order by 4 asc;