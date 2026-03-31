with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        signup_source
,        first_name
,        updated_at
,        account_id
,        created_at
,        country
    from source
)
select * from renamed
