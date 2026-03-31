with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        invoice_date
,        status
,        amount
,        paid_at
,        currency
    from source
)
select * from renamed
