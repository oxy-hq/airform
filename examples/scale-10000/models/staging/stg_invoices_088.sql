with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        due_date
,        paid_at
,        total
    from source
)
select * from renamed
