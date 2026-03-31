with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        invoice_date
,        due_date
,        status
,        currency
,        account_id
,        paid_at
    from source
)
select * from renamed
