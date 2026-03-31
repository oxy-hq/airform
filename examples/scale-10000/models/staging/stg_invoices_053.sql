with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        total
,        tax
,        status
,        currency
,        account_id
,        invoice_date
    from source
)
select * from renamed
