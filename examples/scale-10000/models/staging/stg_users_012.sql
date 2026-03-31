with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        status
,        updated_at
,        account_id
,        signup_source
    from source
)
select * from renamed
