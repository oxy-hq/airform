with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        account_id
,        total
,        currency
,        invoice_date
,        paid_at
    from source
)
select * from renamed
