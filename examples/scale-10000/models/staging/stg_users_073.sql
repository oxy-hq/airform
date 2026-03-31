with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        account_id
,        signup_source
,        status
,        created_at
    from source
)
select * from renamed
