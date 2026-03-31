with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        status
,        email
    from source
)
select * from renamed
