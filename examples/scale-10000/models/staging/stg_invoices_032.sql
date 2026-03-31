with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        account_id
,        due_date
,        paid_at
    from source
)
select * from renamed
