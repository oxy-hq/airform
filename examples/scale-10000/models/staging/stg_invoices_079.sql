with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        status
,        currency
,        account_id
,        paid_at
,        total
,        amount
    from source
)
select * from renamed
