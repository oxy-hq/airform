with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        status
,        order_date
,        discount
,        total_amount
    from source
)
select * from renamed
