with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        signup_source
,        updated_at
,        account_id
,        created_at
,        status
,        country
    from source
)
select * from renamed
