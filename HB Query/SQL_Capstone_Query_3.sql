WITH s AS (
    SELECT r.request_id,
            r.client_name,
            r.room_type,
            r.request_type,
            r.start_date,
            r.end_date,
            r.Adults + r.children AS Occupants,
            rm.id,
            rm.price_day,
            rm.capacity,
            rm.[type],
            rm.prefix,
            IIF(CEILING((r.Adults + r.children)/rm.capacity) = 0, 1,CEILING((r.Adults + r.children)/rm.capacity)) AS No_Potential_Bookings
    FROM requests r
    LEFT JOIN bookings b
    ON r.request_id = b.request_id
    LEFT JOIN rooms rm
    ON r.room_type = rm.[type]
    WHERE b.id IS NULL
) -- CTE

-- Amount lost on unbooked requests: Run line 1 - 37 together
SELECT request_id, 
       Client_name,
       room_type,
       Occupants,
       capacity,
       No_Potential_Bookings,
       price_day, 
       No_Potential_Bookings * price_day AS Revenue_Lost,
       (SELECT SUM(No_Potential_Bookings * price_day) FROM s) AS [Total Revenue Lost]
       -- (SELECT SUM(No_Potential_Bookings * price_day) OVER(PARTITION BY room_type) FROM s) 
FROM s
ORDER BY room_type


-- Revenue Lost Per Room Type
SELECT DISTINCT
       room_type,
       SUM(No_Potential_Bookings * price_day) OVER(PARTITION BY room_type) AS Revenue_Lost
FROM 
    (SELECT r.request_id,
            r.client_name,
            r.room_type,
            r.request_type,
            r.start_date,
            r.end_date,
            r.Adults + r.children AS Occupants,
            rm.id,
            rm.price_day,
            rm.capacity,
            rm.[type],
            rm.prefix,
            IIF(CEILING((r.Adults + r.children)/rm.capacity) = 0, 1,CEILING((r.Adults + r.children)/rm.capacity)) AS No_Potential_Bookings
    FROM requests r
    LEFT JOIN bookings b
    ON r.request_id = b.request_id
    LEFT JOIN rooms rm
    ON r.room_type = rm.[type]
    WHERE b.id IS NULL) AS s;

-- END

/*            Observation          */
-- The normal room lost the highest amount of revenue
-- This is could be due to the limited capacity of the rooms and...
--...the fact that customers would have had to book multiple rooms to meet the capacity requirement (as in No_Potential_Bookings)


-- Multiple Bookings
SELECT rq.client_name,
       count(b.id) as [Number of bookings],
       RANK() OVER(ORDER BY count(b.id) DESC) AS [Ranking]
FROM requests Rq
LEFT JOIN bookings B
ON rq.request_id = b.request_id
GROUP BY rq.client_name

-- Frequent Requests
SELECT rq.client_name,
       count(rq.request_id) as [Number of requests],
       RANK() OVER(ORDER BY count(rq.request_id) DESC) AS [Ranking]
FROM requests Rq
GROUP BY rq.client_name

/*            Suggestion          */
-- Discounts for frequent customers
-- Points accummulated could be spent in the restaurant
