with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        total
,        currency
,        account_id
,        status
    from source
)
select * from renamed
