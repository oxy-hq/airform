with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        account_id
,        invoice_date
,        status
,        amount
,        total
,        currency
    from source
)
select * from renamed
