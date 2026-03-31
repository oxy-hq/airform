with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        account_id
,        amount
,        invoice_date
,        paid_at
,        total
,        tax
    from source
)

select * from renamed
