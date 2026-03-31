with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        due_date
,        account_id
,        tax
,        status
,        total
,        invoice_date
    from source
)
select * from renamed
