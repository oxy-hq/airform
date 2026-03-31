with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        last_name
,        updated_at
,        signup_source
,        country
,        created_at
    from source
)
select * from renamed
