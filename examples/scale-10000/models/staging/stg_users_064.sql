with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        signup_source
,        created_at
,        status
,        last_name
,        country
    from source
)
select * from renamed
