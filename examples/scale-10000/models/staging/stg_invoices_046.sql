with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        tax
,        status
,        amount
,        total
,        paid_at
    from source
)
select * from renamed
