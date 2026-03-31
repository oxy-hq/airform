with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        amount
,        total
,        status
,        due_date
,        invoice_date
,        tax
    from source
)
select * from renamed
