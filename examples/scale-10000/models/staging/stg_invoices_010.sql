with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        total
,        paid_at
,        due_date
,        tax
,        status
,        amount
    from source
)
select * from renamed
