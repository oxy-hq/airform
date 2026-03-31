with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        updated_at
,        signup_source
,        first_name
,        status
,        country
,        account_id
    from source
)
select * from renamed
