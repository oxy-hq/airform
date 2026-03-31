with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        updated_at
,        status
,        last_name
,        account_id
,        first_name
,        signup_source
    from source
)
select * from renamed
