with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        total
,        amount
,        currency
,        invoice_date
,        due_date
,        tax
    from source
)
select * from renamed
