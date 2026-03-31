with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id,
        name as account_name,
        plan_id,
        industry,
        company_size,
        created_at,
        updated_at,
        status,
        billing_email
    from source
)

select * from renamed
