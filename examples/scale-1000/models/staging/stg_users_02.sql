with source as (
    select * from {{ source('raw', 'raw_users') }}
),

renamed as (
    select
        id as user_id
,        email
,        first_name
,        account_id
,        created_at
,        signup_source
,        last_name
    from source
)

select * from renamed
