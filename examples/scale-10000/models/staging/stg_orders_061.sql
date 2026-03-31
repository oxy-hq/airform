with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        tax
,        total_amount
,        order_date
,        discount
,        user_id
    from source
)
select * from renamed
