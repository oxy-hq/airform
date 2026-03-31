with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        account_id
,        total
,        due_date
    from source
)
select * from renamed
