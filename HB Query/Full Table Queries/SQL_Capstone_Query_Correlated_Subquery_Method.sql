WITH Booking_Room AS (
    SELECT  bk.id AS Booking_ID,
            bk.Request_ID,
            rm.id AS Room_id,
            bk.room AS Room_Number,
            rm.Price_Day,
        --     SUM(rm.capacity) OVER (Partition by bk.request_id) AS Capacity,
            rm.capacity,
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

-- Using a correlated subquery to find occupants per booking

SELECT  s.request_id,
        br.Booking_ID,
        br.Room_id AS [Room_ID],
        br.Room_Type,
        s.request_type,
        br.capacity,
        s.No_Bookings,
        s.Total_Occupants/IIF(s.No_Bookings <> 0,s.No_Bookings,1) AS Occupants_per_Booking,
        -- for IIF if no_Bookings = 0 replace it with 1; i.e. if the room was not book but only requested, then total rquested occupants wont divide by 0 but 1 to avoid x/0 = infinity
        br.Room_Number,
        s.Client,
        fm.Menu_ID,
        fm.Menu_Name,
        fm.orders,
        fm.[date] AS Order_Date,
        fm.Time,
        s.start_date AS [Request Start Date],                                                   -- Same as booking start & end dates (except for the year errors in booking table where year = 1916)
        s.end_date AS [Request End Date],
        s.Days,
        br.Price_Day AS Room_Rate,
        (br.price_day * s.Days) AS Hotel_Revenue,                                               -- Room rate * Days  =  Total Revenue 
        ISNULL(fm.Food_Cost,0) AS Food_Revenue,
        ISNULL(fm.Food_Cost,0) + (br.price_day * s.Days) AS Total_Revenue
--INTO Full_Hotel_Table 
FROM    
    (SELECT rq.request_id,
            rq.Request_Type,
            rq.Client_Name AS Client,
            (rq.Adults + rq.Children) AS Total_Occupants,

            (SELECT count(b.booking_ID)
             FROM Booking_Room b                                                                -- correlated subquery to generate no of bookings based on request ID
             WHERE b.request_id = rq.request_id AND b.Booking_ID IS NOT NULL ) AS No_Bookings,  -- For each rq.request_id the subquery finds no of booking_ids when rq.request_id = b.request_id
                                                                                                -- This subquery will make the code take longer to run
             DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
             rq.start_date,
             rq.end_date
    FROM requests AS rq) AS s                                                                   -- Subquery to select the request table with No of bookings per request ID
                                                                                                -- I'm basically selecting from the request table BUT ADDING No_Bookings per requestID
LEFT JOIN Booking_Room as br                                                                    -- Left Joining CTE 1
ON s.request_id = br.request_id
FULL OUTER JOIN FoodOrder_Menu AS fm                                                            -- Outer Joining CTE 2
ON fm.Room = br.Room_Number AND fm.[date] BETWEEN s.start_date AND s.end_date 
ORDER BY s.request_id, Booking_ID ASC

