with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        user_id
,        discount
,        order_date
,        tax
    from source
)
select * from renamed
