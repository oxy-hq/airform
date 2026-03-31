with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        due_date
,        status
,        paid_at
,        account_id
    from source
)
select * from renamed
