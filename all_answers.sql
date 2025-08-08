--EXERCISE 1 - Greeting with Name and Timestamp:
--Create a function greet_user(name TEXT) that returns a greeting message including the name and current timestamp.

DROP FUNCTION IF EXISTS greet_user();

CREATE OR REPLACE FUNCTION greet_user(name TEXT)
RETURNS VARCHAR
LANGUAGE plpgsql AS 
$$
	BEGIN 
		RETURN CONCAT('Greeting Mr\s: ', name, '. The current time and date is: ',current_timestamp);

	END;
$$;

SELECT greet_user('Bob');


-----------------------------------------------------------------------
--EXERCISE 2 - Create Table for Orders:
/* 
Write a stored procedure create_orders_table() that creates a table called orders with:
id (SERIAL primary key)
customer_name (TEXT, not null)
amount (DOUBLE PRECISION, not null) 
*/

DROP PROCEDURE IF EXISTS create_orders_table();

CREATE OR REPLACE PROCEDURE create_orders_table()
LANGUAGE plpgsql AS 
$$
	BEGIN
		CREATE TABLE IF NOT EXISTS orders(
		id SERIAL PRIMARY KEY,
		custumer_name TEXT NOT NULL,
		amount DOUBLE PRECISION NOT NULL
		);
	END;
$$

CALL create_orders_table();


------------------------------------------------
--Exercise 3 — Function to Multiply Three Numbers
--Create a function multiply_three(x DOUBLE PRECISION, y DOUBLE PRECISION, z DOUBLE PRECISION) that returns the product.

DROP FUNCTION IF EXISTS multiply_three();

CREATE OR REPLACE FUNCTION multiply_three(x DOUBLE PRECISION, y DOUBLE PRECISION, z DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql AS
$$
	BEGIN 
		RETURN x*y*z;
	END;
$$;

SELECT multiply_three( 2,8,2)

-- Or the second solution to the same question:

DROP FUNCTION IF EXISTS multiply_three();

CREATE OR REPLACE FUNCTION multiply_three(x DOUBLE PRECISION, y DOUBLE PRECISION, z DOUBLE PRECISION,
OUT sum DOUBLE PRECISION)
--RETURNS DOUBLE PRECISION
LANGUAGE plpgsql AS
$$ 
	BEGIN 
		--RETURN
		sum = x*y*z;
	END;
$$;

SELECT multiply_three(2,8,2)


------------------------------------------------------------
--Exercise 4 — Division and Modulo Function
--Create a function div_mod(a DOUBLE PRECISION, b DOUBLE PRECISION) that returns:
--OUT quotient
--OUT remainder

DROP FUNCTION IF EXISTS div_mod();

CREATE OR REPLACE FUNCTION div_mod(a NUMERIC, b NUMERIC,
OUT quotient NUMERIC,
OUT remainder NUMERIC)
--OUT quotient DOUBLE PRECISION,
--OUT remainder DOUBLE PRECISION)
LANGUAGE plpgsql AS
$$
	BEGIN
		quotient := a / b; 
		remainder := MOD(a::b);  
		--remainder := MOD(a:: numeric , b:: numeric);  
	END;
$$;

SELECT * FROM div_mod(17,5);
		
----------------------------------------------------

--Exercise 5 — Square Root and Power 4
/*Create a function sp_math_roots(x DOUBLE PRECISION, y DOUBLE PRECISION) that returns:

OUT sum_result
OUT diff_result
OUT sqrt_x
OUT y_power_4 */

DROP FUNCTION IF EXISTS sp_math_roots()

CREATE OR REPLACE FUNCTION sp_math_roots(x DOUBLE PRECISION, y DOUBLE PRECISION, 
OUT sum_result DOUBLE PRECISION,
OUT diff_result DOUBLE PRECISION,
OUT sqrt_x DOUBLE PRECISION,
OUT y_power_4 DOUBLE PRECISION)
LANGUAGE plpgsql AS
$$
	BEGIN 
		sum_result := x + y;
		
		IF y := 0 
		THEN 
			diff_result := NULL;
			sqrt_x := NULL;
			y_power_4 := NULL;
		ELSE
			sqrt_x := SQRT(x);
			y_power_4 := POWER(y,4);
			diff_result := x / y;
    	END IF;
				
		
	END;
$$;

SELECT * FROM sp_math_roots(16,3);


-------------------------------------------------

--Exercise 6 — Insert Books and Authors + Get All Books with Publish Year

/*Create a procedure prepare_books_db() that creates and fills tables:

authors(id SERIAL, name TEXT NOT NULL)
books(id SERIAL, title TEXT, price DOUBLE PRECISION, publish_date DATE, author_id INT REFERENCES authors)

Then create a function sp_get_books_with_year() that returns:
title, publish_year, price */

DROP PROCEDURE IF EXISTS prepare_books_db();

CREATE OR REPLACE PROCEDURE prepare_books_db()
LANGUAGE plpgsql AS
$$
	BEGIN
		CREATE TABLE IF NOT EXISTS authors(
		id SERIAL PRIMARY KEY,
		name TEXT NOT NULL);

		CREATE TABLE IF NOT EXISTS books(
		id SERIAL,
		title TEXT,
		price DOUBLE PRECISION,
		publish_date DATE,
		author_id INT REFERENCES authors(id));

		INSERT INTO authors(name) VALUES
		('Alice Munro'), ('George Orwell'), ('Haruki Murakami'), ('Chimamanda Ngozi Adichie');

		INSERT INTO books(title, price, publish_date, author_id) VALUES
		('Lives of Girls and Women', 45.0, '1971-05-01', 1),
		('1984', 30.0, '1949-06-08', 2),
		('Norwegian Wood', 50.0, '1987-09-04', 3),
		('Half of a Yellow Sun', 42.5, '2006-08-15', 4),
		('Kafka on the Shore', 55.0, '2002-01-01', 3),
		('Dear Life', 48.0, '2012-11-13', 1),
		('The Thing Around Your Neck', 35.0, '2009-04-01', 4),
		('Animal Farm', 28.0, '1945-08-17', 2),
		('The Testaments', 60.0, '2019-09-10', 2),
		('Colorless Tsukuru Tazaki', 47.5, '2013-04-12', 3);


	END;
$$

--Summon a CALL to check if ok:
	CALL prepare_books_db();

DROP FUNCTION IF EXISTS sp_get_books_with_year();

CREATE OR REPLACE FUNCTION sp_get_books_with_year()
RETURNS TABLE (title TEXT, publish_year INT, price DOUBLE PRECISION)
-- OUT title TEXT,
-- OUT publish_date DATE,
-- OUT price DOUBLE PRECISION)
LANGUAGE plpgsql AS 
$$
	BEGIN 
		return QUERY
		SELECT books.title, EXTRACT(YEAR FROM publish_date):: INT AS publish_year, books.price FROM books;
	END;
$$

SELECT * FROM sp_get_books_with_year();



----------------------------------------------------

--Exercise 7 — Most Recently Published Book
--Create a function sp_latest_book() that returns the most recent book's title and publish date.
				
DROP FUNCTION IF EXISTS sp_latest_book();

CREATE OR REPLACE FUNCTION sp_latest_book()
RETURNS TABLE(title TEXT, publish_date DATE)
language plpgsql AS
$$
BEGIN
    return QUERY
		select b.title, b.publish_date AS recent_public_date FROM books b ORDER BY b.publish_date DESC LIMIT 1;
END;
$$;

SELECT * FROM sp_latest_book();

-- Just for practicing,  I answered  the question again in another way: 

DROP FUNCTION IF EXISTS sp_latest_book();

CREATE OR REPLACE FUNCTION sp_latest_book( OUT title TEXT, OUT publish_date DATE)
language plpgsql AS
$$
BEGIN
		select b.title, b.publish_date INTO title, publish_date FROM books b ORDER BY b.publish_date DESC LIMIT 1;
END;
$$;

SELECT * FROM sp_latest_book();

-------------------------------------------------------------------

--Exercise 8 — Books Summary Stats
/* 
Create a function sp_books_summary() that returns:
OUT youngest_book DATE
OUT oldest_book DATE
OUT avg_price NUMERIC(5,2)
OUT total_books INT 
*/


DROP FUNCTION IF EXISTS sp_books_summary();

CREATE OR REPLACE FUNCTION sp_books_summary( 
OUT youngest_book DATE,
OUT oldest_book DATE,
OUT avg_price NUMERIC(5,2),
OUT total_books INT)
language plpgsql AS
$$
BEGIN
		SELECT MIN(publish_date), MAX(publish_date), AVG(price), COUNT(*)
		INTO youngest_book, oldest_book, avg_price, total_books
		FROM books;
END;
$$;

SELECT * FROM sp_books_summary();
----------------------------------------------------------

--Exercise 9 — Books by Year Range
--Create a function sp_books_by_year_range(from_year INT, to_year INT) that returns:
--id, title, publish_date, price

DROP FUNCTION IF EXISTS sp_books_by_year_range(from_year INT, to_year INT);

CREATE OR REPLACE FUNCTION sp_books_by_year_range(from_year INT, to_year INT)
RETURNS TABLE (id INT, title TEXT, publish_date DATE, price DOUBLE PRECISION)
LANGUAGE plpgsql AS
$$
	BEGIN 
			RETURN QUERY
			SELECT b.id, b.title, b.publish_date, b.price 
			FROM books b WHERE EXTRACT (YEAR FROM b.publish_date) BETWEEN from_year and to_year;
	END;
$$

SELECT * FROM sp_books_by_year_range(2000, 2010);



		













