with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        title
,        salary
,        last_name
,        manager_id
,        status
,        first_name
    from source
)
select * from renamed
