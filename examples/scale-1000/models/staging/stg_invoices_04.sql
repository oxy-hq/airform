with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        currency
,        total
,        invoice_date
,        due_date
    from source
)

select * from renamed
