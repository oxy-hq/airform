with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        currency
,        tax
,        due_date
,        amount
    from source
)
select * from renamed
