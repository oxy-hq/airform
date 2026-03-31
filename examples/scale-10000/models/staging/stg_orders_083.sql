with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        currency
,        tax
,        user_id
    from source
)
select * from renamed
