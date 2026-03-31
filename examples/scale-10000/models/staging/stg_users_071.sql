with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        signup_source
,        created_at
,        last_name
,        account_id
,        country
    from source
)
select * from renamed
