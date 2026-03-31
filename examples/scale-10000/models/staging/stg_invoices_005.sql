with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        total
,        currency
,        status
,        invoice_date
,        paid_at
,        due_date
    from source
)
select * from renamed
