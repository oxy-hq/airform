with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        discount
,        currency
,        user_id
,        total_amount
    from source
)
select * from renamed
