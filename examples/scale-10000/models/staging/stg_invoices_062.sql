with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        amount
,        total
,        status
,        currency
,        due_date
,        invoice_date
    from source
)
select * from renamed
