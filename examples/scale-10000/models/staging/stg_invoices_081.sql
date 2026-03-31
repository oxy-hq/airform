with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        paid_at
,        invoice_date
,        account_id
    from source
)
select * from renamed
