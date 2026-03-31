with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        due_date
,        account_id
,        amount
,        paid_at
    from source
)
select * from renamed
