with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        first_name
,        updated_at
,        created_at
,        account_id
,        signup_source
,        country
    from source
)
select * from renamed
