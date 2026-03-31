with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        amount
,        account_id
,        status
,        currency
    from source
)

select * from renamed
