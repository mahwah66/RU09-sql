USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name` from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name from actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * from actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * from actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country from country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
ADD description BLOB; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. 
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name,  COUNT(  last_name ) AS Count
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name,  COUNT(  last_name ) AS Count
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- 'address', 'CREATE TABLE `address` (\n  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,\n  `address` varchar(50) NOT NULL,\n  `address2` varchar(50) DEFAULT NULL,\n  `district` varchar(20) NOT NULL,\n  `city_id` smallint(5) unsigned NOT NULL,\n  `postal_code` varchar(10) DEFAULT NULL,\n  `phone` varchar(20) NOT NULL,\n  `location` geometry NOT NULL,\n  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n  PRIMARY KEY (`address_id`),\n  KEY `idx_fk_city_id` (`city_id`),\n  SPATIAL KEY `idx_location` (`location`),\n  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE\n) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON
staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) as `August 2005 Total`
FROM payment
INNER JOIN staff ON
staff.staff_id=payment.staff_id
WHERE payment.payment_date like '2005-08%'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) as `Number of Actors`
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT  COUNT(inventory_id) AS `Hunchback Impossible copies`
FROM inventory
WHERE film_id IN
(
     SELECT film_id
     FROM film
     WHERE title = 'Hunchback Impossible'
);
   
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) as `Total Amount Paid`
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name, customer.first_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE language_id IN
(
	SELECT language_id FROM language
    WHERE name = "English"
) AND (title LIKE "K%" OR title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
(
	SELECT actor_id FROM film_actor
	WHERE film_ID IN
	(
		SELECT film_id FROM film
		WHERE title = "Alone Trip"
	)
);

-- 7c. you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email
FROM customer as c
INNER JOIN address as a ON c.address_id = a.address_id
INNER JOIN city as ct ON ct.city_id = a.city_id
INNER JOIN country as cy ON ct.country_id = cy.country_id
WHERE cy.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title
	FROM film as f
	JOIN film_category as fc
	ON fc.film_id = f.film_id
	JOIN category as c
	ON c.category_id = fc.category_id
	WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS `Times Rented`
	FROM film f
    JOIN inventory i
    ON (f.film_id = i.film_id)
    JOIN rental r
    ON (i.inventory_id = r.inventory_id)
    GROUP BY f.title
    ORDER BY `Times Rented` DESC, f.title ASC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) AS Gross
	From payment p
    JOIN rental r
    ON (p.rental_id = r.rental_id)
    JOIN inventory i
    ON (i.inventory_id = r.inventory_id)
    JOIN store s
    ON (s.store_id = i.store_id)
    GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, n.country
	From country n
    JOIN city c
    ON (n.country_id = c.country_id)
    JOIN address a
    ON (a.city_id = c.city_id)
    JOIN store s
    ON (a.address_id = s.address_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name,  SUM(p.amount) AS Gross 
	FROM category c
    JOIN film_category fc
    ON (c.category_id = fc.category_id)
    JOIN inventory i
    ON (fc.film_id = i.film_id)
    JOIN rental r
    ON (i.inventory_id = r.inventory_id)
    JOIN payment p
    ON (r.rental_id = p.rental_id)
    GROUP BY c.name
    ORDER BY Gross DESC
    Limit 5;

-- 8a. Use the solution from the problem above to create a view. 
CREATE VIEW top_five_genres AS
SELECT c.name,  SUM(p.amount) AS Gross 
	FROM category c
    JOIN film_category fc
    ON (c.category_id = fc.category_id)
    JOIN inventory i
    ON (fc.film_id = i.film_id)
    JOIN rental r
    ON (i.inventory_id = r.inventory_id)
    JOIN payment p
    ON (r.rental_id = p.rental_id)
    GROUP BY c.name
    ORDER BY Gross DESC
    Limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres; 
