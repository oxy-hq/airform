with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        hire_date
,        manager_id
,        status
,        first_name
,        last_name
,        department_id
    from source
)
select * from renamed
