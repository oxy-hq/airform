with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        total
,        currency
,        amount
,        account_id
,        due_date
,        invoice_date
,        status
    from source
)
select * from renamed
