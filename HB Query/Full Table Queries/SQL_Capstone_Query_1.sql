



/*          Observations            */
-- Multiple null values in booking start and stop dates
-- Inconsistent dates (year = 1916) in bookings table
-- Inconsistent spelling in Room type for request table so need to use PK in Room table for joining 
-- Occupants were more than capacity - corrected using window function
-- No PK in food order table. This would've made joining to Room table easier

/*          Steps taken             *
*Create DB
*Imported tables into DB
*Listed all tables to identify rxnships
*Joined request and booking tables
*Joined request, booking and room tables
-- *Created CTE for booking and room to import Room ID on rm.prefix = bk.room
-- *Left Join booking_room CTE and request booking table
*Created Food order and Menu tables and declared it as a CTE
*Outer Join Foodorder/Menu CTE and main table on booking room and date stayed to find people who ordered meals during their stay
*Added financial implications Food costs, Hotel costs and Total costs
*Populated only necessary information and inported into full table
*/

--1). Create DB
--CREATE DATABASE CapstoneProjectDB
--2). Check DB
--SELECT name FROM sys.Databases WHERE name = 'CapstoneProjectDB'
--SELECT * FROM sys.Databases Validation

--3). list all tables
-- SELECT * FROM requests
-- SELECT * FROM bookings --left & main table
-- SELECT * FROM rooms;
-- SELECT * FROM food_orders
-- SELECT * FROM menu

-- 4)
-- CTE for joining Booking and Room tables
WITH Booking_Room AS (
    SELECT bk.id AS Booking_ID,
            bk.Request_ID,
            rm.id AS Room_id,
            bk.room AS Room_Number,
            rm.Price_Day,
            rm.Capacity,
            rm.[type] AS Room_Type,
            rm.prefix AS Room_Prefix           
    FROM bookings AS bk
    LEFT JOIN rooms AS rm
    ON rm.prefix = SUBSTRING(bk.room,1,1)
), FoodOrder_Menu AS (
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

/*                  Join Request, Booking, and Room Tables                  */
-- SELECT
--     DISTINCT rq.request_id AS [Request ID],
--     br.booking_id AS [Booking ID],
--     br.Room_id AS [Room ID],
--     -- br.Room_Type,
--     br.Room_Number,
--     rq.Request_Type,
--     br.Capacity,
--     rq.adults + rq.children AS Occupants,
--     rq.Client_Name AS Client,
--     DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
--     br.Price_Day AS Rate,
--     br.price_day * DATEDIFF(DAY,rq.start_date,rq.end_date) AS Cost
--     -- rq.start_date AS [Request Start Date],
--     -- rq.end_date AS [Request End Date],
--     -- bk.start_date,
--     -- bk.end_date
--     -- DATEDIFF(DAY,rq.start_date,bk.start_date) AS [Request and Booking Start Date Difference]
--     -- DATEDIFF(DAY,rq.end_date,bk.end_date) AS [Request and Booking End Date Difference], 
-- FROM requests AS rq
-- LEFT JOIN bookings AS bk 
-- ON rq.request_id = bk.request_id
-- LEFT JOIN booking_room AS br
-- ON rq.request_id = br.request_id


-- **Insert pk in food order table

/*                      Join food order and menu tables                     */
-- SELECT 
--         mn.id AS Menu_ID,
--         mn.name AS Menu_Name],
--         mn.Category,
--         fo.bill_room AS Room,
--         mn.Price,
--         fo.Orders,
--         mn.price * fo.orders AS Food_Cost,
--         fo.[Date],
--         fo.[Time]
-- FROM food_orders AS fo
-- LEFT JOIN menu AS mn
-- ON fo.menu_id = mn.id
-- Join food order/menu on room type


-- Join food order/menu on booking room and date stayed
-- Join all tables
SELECT DISTINCT 
    rq.request_id AS [Request ID],
    br.booking_id AS [Booking ID],
    br.Room_id AS [Room ID],
    br.Room_Type,
    br.Room_Number,
    rq.Request_Type,
    br.Capacity,
    rq.adults + rq.children AS Occupants,
    rq.Client_Name AS Client,
    fm.Menu_ID,
    fm.Menu_Name,
    fm.orders,
    fm.Time,
    DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
    br.Price_Day AS Room_Rate,
    br.price_day * DATEDIFF(DAY,rq.start_date,rq.end_date) AS Hotel_Cost,
    ISNULL(fm.Food_Cost,0) AS Food_Cost,
    ISNULL(fm.Food_Cost,0) + br.price_day * DATEDIFF(DAY,rq.start_date,rq.end_date) AS Total_Cost,
    rq.start_date AS [Request Start Date]
    -- rq.end_date AS [Request End Date],
    -- bk.start_date,                                                                                   -- contains errors(null values)
    -- bk.end_date ,                                                                                    -- contains errors(null values)
    -- DATEDIFF(DAY,rq.start_date,bk.start_date) AS [Request and Booking Start Date Difference],        -- Checks for variation between request and booking start dates
    -- DATEDIFF(DAY,rq.end_date,bk.end_date) AS [Request and Booking End Date Difference]               -- Checks for variation between request and booking start dates
-- INTO Full_Hotel_Table                                                                                -- Create Full Hotel Table 
-- INTO ID_Table                                                                                        -- Create ID Table
FROM requests AS rq
LEFT JOIN bookings AS bk 
ON rq.request_id = bk.request_id
LEFT JOIN Booking_Room AS br
ON rq.request_id = br.request_id
FULL OUTER JOIN FoodOrder_Menu AS fm
ON fm.Room = br.Room_Number AND fm.[date] BETWEEN rq.start_date AND rq.end_date
-- WHERE bk.id IS NOT NULL


