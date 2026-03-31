with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        paid_at
,        invoice_date
,        tax
,        due_date
,        total
,        currency
    from source
)
select * from renamed
