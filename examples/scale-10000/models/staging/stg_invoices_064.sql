with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        total
,        paid_at
,        amount
,        account_id
,        tax
,        due_date
    from source
)
select * from renamed
