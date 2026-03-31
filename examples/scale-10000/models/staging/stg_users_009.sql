with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        created_at
,        email
,        account_id
,        first_name
,        status
,        signup_source
    from source
)
select * from renamed
