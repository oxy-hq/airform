with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        order_date
,        discount
,        status
    from source
)
select * from renamed
