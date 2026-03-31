with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        account_id
,        due_date
,        amount
    from source
)
select * from renamed
