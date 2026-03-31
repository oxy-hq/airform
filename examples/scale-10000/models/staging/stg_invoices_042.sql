with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        tax
,        total
,        status
    from source
)
select * from renamed
