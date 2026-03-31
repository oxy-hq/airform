with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        paid_at
,        total
,        invoice_date
,        account_id
,        amount
,        currency
    from source
)
select * from renamed
