with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        reference_id
,        fee
,        processed_at
    from source
)
select * from renamed
