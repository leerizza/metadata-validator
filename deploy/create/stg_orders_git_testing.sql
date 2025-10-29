CREATE TABLE [dbo].[stg_orders_git_testing](
    order_id int NOT NULL,
    order_date DATETIME2 NOT NULL,
    customer_name varchar(100) NOT NULL,
    amount decimal(18,2) NOT NULL,
    CONSTRAINT PK_stg_orders_git_testing PRIMARY KEY CLUSTERED (order_id)
);