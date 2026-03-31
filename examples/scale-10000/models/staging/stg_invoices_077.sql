with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        total
,        currency
,        account_id
    from source
)
select * from renamed
