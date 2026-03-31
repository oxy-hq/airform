with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        total
,        tax
,        due_date
,        paid_at
,        status
    from source
)
select * from renamed
