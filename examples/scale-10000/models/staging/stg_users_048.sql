with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        account_id
,        first_name
,        signup_source
,        created_at
,        country
,        updated_at
    from source
)
select * from renamed
