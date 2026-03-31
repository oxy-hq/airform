with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        invoice_date
,        due_date
,        tax
,        amount
,        total
,        status
    from source
)
select * from renamed
