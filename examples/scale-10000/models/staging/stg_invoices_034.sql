with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        status
,        currency
,        account_id
,        tax
,        total
,        invoice_date
    from source
)
select * from renamed
