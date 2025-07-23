# Hotel Bookings: Uncovering Insights Through Data Analysis 📊



### Project Highlights:
Welcome to the **Hotel Bookings Descriptive Analysis** project! 
 This repository serves as a comprehensive demonstration of my capabilities in **data management, data mining best practices, BI reporting, and end-to-end data engineering workflows (preparation and transformation)**. My primary objective was to derive actionable insights from real-world hotel data, specifically focusing on booking patterns, revenue opportunities, and operational efficiency to support strategic decision-making.

### Project Breakdown:

* **Data Acquisition & Storage:**
    * The raw data, simulated from a hotel management system, is stored as `.csv` files within the `tables` folder. This includes detailed information on bookings, food orders, menu items, guest requests, and room configurations.

* **SQL for Robust Data Transformation:**
    * I extensively utilized **SQL queries** (located in the `HB Query` folder) for the critical phases of **data cleaning, manipulation, and transformation**. This involved:
        * **Identifying Revenue Loss:** A key analysis focused on calculating `Revenue_Lost` from unbooked requests, particularly for specific `room_type`s. For instance, one query (shown below) precisely quantifies this potential loss by joining `requests`, `bookings`, and `rooms` tables, allowing us to pinpoint areas for improvement.
        * **Analyzing Customer Behavior:** Queries were also developed to identify **multiple bookings** and **frequent requests** from clients, laying the groundwork for potential loyalty programs or targeted offers.

    ```sql
    -- Example: Calculating Revenue Lost Per Room Type from unbooked requests
    SELECT DISTINCT
        room_type,
        SUM(No_Potential_Bookings * price_day) OVER(PARTITION BY room_type) AS Revenue_Lost
    FROM
        (SELECT r.request_id,
                r.client_name,
                r.room_type,
                r.Adults + r.children AS Occupants,
                rm.price_day,
                IIF(CEILING((r.Adults + r.children)/rm.capacity) = 0, 1,CEILING((r.Adults + r.children)/rm.capacity)) AS No_Potential_Bookings
        FROM requests r
        LEFT JOIN bookings b ON r.request_id = b.request_id
        LEFT JOIN rooms rm ON r.room_type = rm.[type]
        WHERE b.id IS NULL) AS s;
    ```
    * **_Observation:_** Analysis revealed that "normal" rooms contributed to the highest amount of lost revenue, potentially due to limited capacity requiring multiple bookings for larger groups. This highlights an area for strategic review.

* **Power BI for Dynamic Visualization:**
    * The transformed data was then imported into **Power BI** for advanced cleaning, modeling, and the creation of **interactive dashboards**. These dashboards (local files in the `Dashboards` folder) visually communicate key performance indicators, trends, and areas requiring attention, enabling stakeholders to make data-driven decisions.

### Interactive Dashboards:



![Dashboard 1](https://user-images.githubusercontent.com/99233674/191894962-61f16027-05e2-4632-991d-dd1bd4e3fb3a.jpg)
![Dashboard 2](https://user-images.githubusercontent.com/99233674/191894971-f68ee1f2-0c92-4b7a-9366-8bacaa762938.jpg)
![Dashboard 3](https://user-images.githubusercontent.com/99233674/191894980-1736ae36-2d76-4489-b9f3-791f58117602.jpg)
