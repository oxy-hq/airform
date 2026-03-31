with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        country
,        status
,        first_name
,        account_id
    from source
)
select * from renamed
