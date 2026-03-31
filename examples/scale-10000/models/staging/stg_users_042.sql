with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        signup_source
,        country
,        account_id
,        first_name
,        last_name
,        updated_at
    from source
)
select * from renamed
