with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        invoice_date
,        due_date
,        amount
,        tax
,        total
,        status
,        account_id
    from source
)
select * from renamed
