with source as (
    select * from {{ source('raw', 'raw_users') }}
),

renamed as (
    select
        id as user_id,
        account_id,
        email,
        first_name,
        last_name,
        created_at,
        updated_at,
        status,
        country,
        signup_source
    from source
)

select * from renamed
