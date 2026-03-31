with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        first_name
,        status
,        signup_source
,        country
,        account_id
,        created_at
    from source
)
select * from renamed
