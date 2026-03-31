with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        email
,        updated_at
,        signup_source
,        created_at
,        last_name
,        account_id
    from source
)
select * from renamed
