with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        invoice_date
,        status
,        account_id
,        amount
,        due_date
,        tax
,        currency
    from source
)
select * from renamed
