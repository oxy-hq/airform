with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        order_date
,        status
,        tax
,        user_id
,        discount
,        total_amount
    from source
)
select * from renamed
