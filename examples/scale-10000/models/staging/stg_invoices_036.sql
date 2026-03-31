with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        tax
,        status
,        currency
,        invoice_date
,        due_date
,        paid_at
    from source
)
select * from renamed
