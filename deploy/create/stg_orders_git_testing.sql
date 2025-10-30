CREATE TABLE [dbo].[stg_orders_git_testing](
    order_id INT NOT NULL,
    order_date DATETIME2 NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_stg_orders_git_testing PRIMARY KEY CLUSTERED (order_id)
);