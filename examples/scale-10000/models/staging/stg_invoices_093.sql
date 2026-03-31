with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        total
,        account_id
,        currency
,        due_date
,        invoice_date
,        status
    from source
)
select * from renamed
