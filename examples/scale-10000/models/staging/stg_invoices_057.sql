with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        account_id
,        paid_at
,        invoice_date
,        status
    from source
)
select * from renamed
