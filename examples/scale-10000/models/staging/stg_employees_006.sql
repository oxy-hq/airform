with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        last_name
,        title
,        email
,        status
,        salary
    from source
)
select * from renamed
