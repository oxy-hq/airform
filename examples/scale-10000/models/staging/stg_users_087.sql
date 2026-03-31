with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        signup_source
,        status
,        account_id
,        country
,        updated_at
,        first_name
    from source
)
select * from renamed
