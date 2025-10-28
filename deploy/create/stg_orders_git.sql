IF OBJECT_ID(N'[dbo].[stg_orders_git]','U') IS NULL
BEGIN
    CREATE TABLE [dbo].[stg_orders_git](
        order_id INT NOT NULL,
        order_date DATETIME2 NOT NULL,
        customer_name VARCHAR(200) NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_stg_orders_git PRIMARY KEY CLUSTERED (order_id)
    );
END;