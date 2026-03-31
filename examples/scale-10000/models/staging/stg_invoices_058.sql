with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        status
,        amount
,        account_id
,        currency
,        total
,        tax
    from source
)
select * from renamed
