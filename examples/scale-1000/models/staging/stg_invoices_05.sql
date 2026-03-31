with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id
,        invoice_date
,        account_id
,        status
,        total
    from source
)

select * from renamed
