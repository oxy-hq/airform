with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        paid_at
,        tax
,        status
,        total
,        currency
,        due_date
    from source
)
select * from renamed
