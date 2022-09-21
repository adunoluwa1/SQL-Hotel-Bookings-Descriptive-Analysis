WITH Booking_Room AS (
    SELECT  bk.id AS Booking_ID,
            bk.Request_ID,
            rm.id AS Room_id,
            bk.room AS Room_Number,
            rm.Price_Day,
            SUM(rm.capacity) OVER (Partition by bk.request_id) AS Capacity,
            rm.[type] AS Room_Type,
            rm.prefix AS Room_Prefix           
    FROM bookings AS bk
    LEFT JOIN rooms AS rm
    ON rm.prefix = SUBSTRING(bk.room,1,1)
),   FoodOrder_Menu AS (
SELECT 
        mn.id AS Menu_ID,
        mn.name AS Menu_Name,
        mn.Category,
        fo.bill_room AS Room,
        mn.Price,
        fo.Orders,
        mn.price * fo.orders AS Food_Cost,
        fo.[Date],
        fo.[Time]
FROM food_orders AS fo
LEFT JOIN menu AS mn
ON fo.menu_id = mn.id
)


-- SELECT DISTINCT 
--     rq.request_id AS [Request_ID],
--     br.booking_id AS [Booking_ID],
--     br.Room_id AS [Room_ID],
--     br.Room_Type,
--     br.Room_Number,
--     rq.Request_Type,
--     br.Capacity,
--     rq.adults + rq.children AS Occupants,
--     rq.Client_Name AS Client,
--     fm.Menu_ID,
--     fm.Menu_Name,
--     fm.orders,
--     fm.Time,
--     DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
--     br.Price_Day AS Room_Rate,
--     br.price_day * DATEDIFF(DAY,rq.start_date,rq.end_date) AS Hotel_Cost,
--     ISNULL(fm.Food_Cost,0) AS Food_Cost,
--     ISNULL(fm.Food_Cost,0) + br.price_day * DATEDIFF(DAY,rq.start_date,rq.end_date) AS Total_Cost,
--     rq.start_date AS [Request Start Date]
--     -- rq.end_date AS [Request End Date],
--     -- bk.start_date,                                                                                   -- contains errors(null values)
--     -- bk.end_date ,                                                                                    -- contains errors(null values)
--     -- DATEDIFF(DAY,rq.start_date,bk.start_date) AS [Request and Booking Start Date Difference],        -- Checks for variation between request and booking start dates
--     -- DATEDIFF(DAY,rq.end_date,bk.end_date) AS [Request and Booking End Date Difference]               -- Checks for variation between request and booking start dates
-- -- INTO Full_Hotel_Table                                                                                -- Create Full Hotel Table 
-- -- INTO ID_Table                                                                                        -- Create ID Table
-- FROM requests AS rq
-- LEFT JOIN bookings AS bk 
-- ON rq.request_id = bk.request_id
-- LEFT JOIN Booking_Room AS br
-- ON rq.request_id = br.request_id
-- FULL OUTER JOIN FoodOrder_Menu AS fm
-- ON fm.Room = br.Room_Number AND fm.[date] BETWEEN rq.start_date AND rq.end_date
-- -- WHERE bk.id IS NOT NULL


-- -- Correcting the Capacity by splitting the requested occupants between the number of rooms 
-- SELECT  
--         s.Request_ID,
--         s.Room_type,
--         s.Occupants/s.No_Bookings AS Occupants_per_booking,
--         s.capacity 
-- FROM 
--     (SELECT rq.Request_ID,
--             rm.[type] AS Room_type,
--             rq.Adults + rq.Children AS Occupants,
--             rm.Capacity, 
--             SUM(rm.capacity) OVER (Partition by rq.request_id) AS Total_Capacity,
--             count(bk.id) OVER(PARTITION BY rq.request_ID) AS No_Bookings
--      FROM requests as rq
--      LEFT JOIN bookings as bk
--      ON rq.request_ID = bk.request_id
--      LEFT JOIN rooms as rm
--      ON rm.prefix = SUBSTRING(bk.room,1,1)
--      WHERE bk.id IS NOT NULL -- Excludes requests that were not booked
--           ) AS s


-- -- Using total capacity of rooms(bookings) per request id 
-- SELECT rq.Request_ID,
--        rm.[type] AS Room_type,
--        rq.Adults + rq.Children AS Occupants,
--        rm.Capacity, 
--        SUM(rm.capacity) OVER (Partition by rq.request_id) AS Total_Capacity
-- FROM requests as rq
-- LEFT JOIN bookings as bk
-- ON rq.request_ID = bk.request_id
-- LEFT JOIN rooms as rm
-- ON rm.prefix = SUBSTRING(bk.room,1,1)
-- WHERE bk.id IS NOT NULL

-- Using correlated subqueries to find the Occupants per room
SELECT  s.request_id,
        b.Booking_ID,
        b.capacity,
        s.Total_Occupants/IIF(s.No_Bookings <> 0,s.No_Bookings,1) AS Occupants_per_Room
FROM    
    (SELECT rq.request_id,
            (rq.Adults + rq.Children) AS Total_Occupants,
            (SELECT count(br.booking_ID)
             FROM Booking_Room br
             WHERE br.request_id = rq.request_id AND br.Booking_ID IS NOT NULL ) AS No_Bookings
    FROM requests AS rq) AS s
LEFT JOIN Booking_Room as b
ON s.request_id = b.request_id