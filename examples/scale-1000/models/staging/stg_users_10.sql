with source as (
    select * from {{ source('raw', 'raw_users') }}
),

renamed as (
    select
        id as user_id
,        created_at
,        first_name
,        account_id
,        updated_at
,        country
,        signup_source
    from source
)

select * from renamed
