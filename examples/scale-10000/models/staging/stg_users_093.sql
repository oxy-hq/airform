with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        country
,        account_id
,        email
,        first_name
,        status
    from source
)
select * from renamed
