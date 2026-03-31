with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        currency
,        status
,        invoice_date
,        due_date
,        account_id
    from source
)
select * from renamed
