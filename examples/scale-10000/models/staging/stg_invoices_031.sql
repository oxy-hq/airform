with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        tax
,        amount
    from source
)
select * from renamed
