with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        discount
,        tax
,        order_date
,        account_id
,        total_amount
    from source
)
select * from renamed
