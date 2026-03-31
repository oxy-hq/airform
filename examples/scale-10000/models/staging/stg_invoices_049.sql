with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        paid_at
,        invoice_date
,        tax
,        amount
,        due_date
,        total
    from source
)
select * from renamed
