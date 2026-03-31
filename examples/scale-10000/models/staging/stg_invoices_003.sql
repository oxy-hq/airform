with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        total
,        due_date
,        paid_at
,        account_id
,        amount
,        currency
    from source
)
select * from renamed
