with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        status
,        salary
,        first_name
,        manager_id
,        last_name
    from source
)
select * from renamed
