with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),
renamed as (
    select
        id as invoice_id
,        account_id
,        status
,        total
,        due_date
,        tax
    from source
)
select * from renamed
