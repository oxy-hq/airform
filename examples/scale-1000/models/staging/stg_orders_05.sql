with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        currency
,        order_date
,        tax
,        status
    from source
)

select * from renamed
