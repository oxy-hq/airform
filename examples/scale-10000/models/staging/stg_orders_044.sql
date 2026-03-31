with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        order_date
,        tax
,        currency
,        status
    from source
)
select * from renamed
