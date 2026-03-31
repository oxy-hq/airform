with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        user_id
,        order_date
,        status
,        total_amount
,        discount
,        tax
    from source
)
select * from renamed
