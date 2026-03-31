with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        account_id
,        paid_at
,        tax
,        amount
,        status
,        total
    from source
)
select * from renamed
