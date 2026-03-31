with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        status
,        account_id
,        tax
,        paid_at
,        currency
,        total
    from source
)
select * from renamed
