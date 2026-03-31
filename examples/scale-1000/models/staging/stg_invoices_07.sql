with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        account_id
,        amount
,        total
,        paid_at
,        currency
,        tax
    from source
)

select * from renamed
