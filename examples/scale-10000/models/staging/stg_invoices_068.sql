with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        invoice_date
,        tax
,        currency
,        paid_at
,        total
,        account_id
    from source
)
select * from renamed
