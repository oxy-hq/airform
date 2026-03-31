with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        total
,        amount
,        account_id
,        status
,        paid_at
,        tax
    from source
)
select * from renamed
