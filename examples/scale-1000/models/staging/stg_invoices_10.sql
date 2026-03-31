with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        total
,        paid_at
,        invoice_date
,        due_date
,        status
,        tax
,        amount
    from source
)

select * from renamed
