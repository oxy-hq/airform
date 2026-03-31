with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        account_id
,        currency
,        total
,        invoice_date
,        amount
    from source
)
select * from renamed
