with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        country
,        updated_at
,        first_name
,        signup_source
,        last_name
,        email
    from source
)
select * from renamed
