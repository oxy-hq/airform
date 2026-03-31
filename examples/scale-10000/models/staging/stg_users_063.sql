with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        updated_at
,        account_id
,        created_at
,        signup_source
,        last_name
,        first_name
    from source
)
select * from renamed
