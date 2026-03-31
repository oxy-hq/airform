with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        email
,        created_at
,        account_id
,        signup_source
,        last_name
    from source
)
select * from renamed
