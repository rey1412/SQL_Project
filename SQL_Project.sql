
--Who is the senior most employee based on job title?

SELECT TOP 1 * from employee e
ORDER by e.levels DESC;

--Write query to fetch employee name and manager name from the same table?

SELECT e.first_name 
       ,m.first_name as manager_name
FROM employee e 
    inner JOIN employee m 
    ON e.reports_to = m.employee_id

--Which countries have the most Invoices?

SELECT i.billing_country
       ,count(i.invoice_id) as Count_of_Invoice
FROM invoice i
GROUP BY i.billing_country
ORDER BY 2 desc;

--What are TOP 3 values of total invoice?

SELECT TOP 3 total as TOP_3 from invoice i
ORDER BY i.total DESC ;

--Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

SELECT TOP 1 billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC

--Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money

SELECT TOP 1 c.customer_id
       ,sum(i.total) as totalmoneyspent FROM customer c
 INNER JOIN invoice i      
ON c.customer_id=i.customer_id
group by c.customer_id
order by totalmoneyspent desc

--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A

SELECT c.first_name
       ,c.last_name
       ,c.email
       ,g.name
        from customer c
INNER JOIN invoice i 
ON c.customer_id=i.customer_id
INNER JOIN invoice_line l 
ON l.invoice_id=i.invoice_id
INNER JOIN track t 
ON l.track_id =t.track_id
INNER JOIN genre g 
ON t.genre_id =g.genre_id
WHERE g.name ='Rock'
ORDER BY c.email;

--Let's invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT TOP 10 ar.name
       ,Sum(t.track_id) as total_count
        FROM artist ar
INNER JOIN album2 ab 
ON ar.artist_id=ab.artist_id
INNER JOIN track t
ON ab.album_id=t.album_id
INNER JOIN genre g 
ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
GROUP by ar.name
ORDER BY 2 DESC

--Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

Select [name],
       milliseconds 
       FROM track
 WHERE milliseconds > (select AVG(milliseconds) as Avg_Song_Length 
                     from track
                     )
order by 2  desc   

--Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent

WITH artistamount AS 
(
       SELECT artist.artist_id
              ,artist.name
              ,SUM(invoice_line.unit_price * invoice_line.quantity) as totalmoneyspent
       FROM invoice_line
       INNER JOIN track
       ON invoice_line.track_id=track.track_id
       INNER JOIN album2
       ON track.album_id=album2.album_id
       INNER JOIN artist
       ON album2.artist_id=artist.artist_id
       GROUP by artist.artist_id
       
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN artistamount bsa ON bsa.artist_id = alb.artist_id
ORDER BY 5 DESC;

--We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases 
           ,customer.country
           ,genre.name
           ,genre.genre_id, 
	    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country
              ,genre.name
              ,genre.genre_id
	
)
SELECT * FROM popular_genre 
WHERE RowNo <= 1
ORDER BY popular_genre.country ASC, 1 DESC

--Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

WITH moneyspent AS 
(  
       select customer.customer_id
              ,customer.first_name
              ,customer.last_name
              ,customer.country
              ,Sum(invoice.total) as Totalspent
              ,Rank() OVER( PARTITION BY customer.country order BY Sum(invoice.total)Desc) x
       from customer
        INNER JOIN invoice
        ON customer.customer_id=invoice.customer_id
        GROUP BY customer.customer_id
                 ,customer.first_name
                 ,customer.last_name
                 ,customer.country
)
SELECT * FROM moneyspent
WHERE x <=1
ORDER BY Totalspent desc

