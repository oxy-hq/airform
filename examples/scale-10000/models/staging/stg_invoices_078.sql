with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        currency
,        tax
,        status
,        amount
    from source
)
select * from renamed
