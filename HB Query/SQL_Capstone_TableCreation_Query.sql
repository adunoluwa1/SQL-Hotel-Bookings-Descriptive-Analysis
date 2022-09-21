/*          Request/Booking/Room            */
    
SELECT DISTINCT
        sub.Booking_id,
        sub.request_id,
        sub.Room_id,
        sub.Room_Number,
        sub.Room_Prefix,
        sub.Room_Type,
        sub.request_type,
        sub.client_Name,
        sub.capacity,
        sub.Start_Date,
        sub.End_Date,
        sub.Occupants/IIF(sub.No_Bookings <> 0, sub.No_Bookings,1) AS Occupants,
        sub.Days  * sub.Room_Rate AS Hotel_Cost
-- INTO Booking_Request_Room
FROM (SELECT  bk.id AS Booking_ID,
            bk.Request_ID,
            rm.id AS Room_id,
            bk.room AS Room_Number,
            rm.capacity,
            rq.Adults + rq.Children AS Occupants,
            (SELECT count(b.id)
            FROM bookings b
            WHERE rq.request_ID = b.request_ID) AS No_Bookings,
            rm.[type] AS Room_Type,
            rm.prefix AS Room_Prefix,           
            rm.Price_Day AS Room_Rate,
            DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
            rq.start_date,
            rq.end_date,
            rq.client_name,
            rq.request_type
        --     SUM(rm.capacity) OVER (Partition by bk.request_id) AS Capacity,
    FROM bookings AS bk
    LEFT JOIN rooms AS rm
    ON rm.prefix = SUBSTRING(bk.room,1,1)
    LEFT JOIN requests AS rq 
    ON bk.request_id = rq.request_id) AS sub

/*          FoodOrder/Menu           */
-- SELECT 
--         mn.id AS Menu_ID,
--         mn.Category,
--         mn.name AS Menu_Name,
--         fo.bill_room AS Room,
--         Rm.[type] AS Room_Type,
--         SUBSTRING(fo.bill_room,1,1) AS Room_Prefix,
--         fo.dest_room AS Destination,
--         fo.Orders,
--         mn.price * fo.orders AS Food_Cost,
--         fo.[Date],
--         fo.[Time]
-- -- INTO Food_Order_Menu
-- FROM food_orders AS fo
-- LEFT JOIN menu AS mn
-- ON fo.menu_id = mn.id
-- LEFT JOIN rooms AS Rm 
-- ON SUBSTRING(fo.bill_room,1,1) = Rm.prefix

/*          Request/Booking           */
-- SELECT    
--        Bk.id AS Booking_ID,
--        Rq.Request_ID,
--        Rq.request_type,
--        Bk.Room,
--        Substring(Bk.Room,1,1) AS Room_Prefix,
--        Rq.room_type,
--        Rq.Start_Date,
--        Rq.End_Date,
--        Rq.Adults + Rq.Children AS Occupants
-- -- INTO Request_Booking
-- FROM Requests Rq 
-- LEFT JOIN Bookings Bk 
-- ON Rq.Request_ID = Bk.Request_ID

-- DROP TABLE Food_Order_Menu
