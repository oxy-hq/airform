with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        currency
,        status
,        invoice_date
,        total
    from source
)
select * from renamed
