with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        amount
,        status
,        invoice_date
,        paid_at
,        total
    from source
)
select * from renamed
