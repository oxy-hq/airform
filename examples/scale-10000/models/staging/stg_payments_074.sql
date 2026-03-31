with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        status
,        reference_id
    from source
)
select * from renamed
