with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        amount
,        paid_at
,        total
,        due_date
,        status
    from source
)
select * from renamed
