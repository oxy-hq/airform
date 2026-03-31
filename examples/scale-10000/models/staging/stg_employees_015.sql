with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        salary
,        hire_date
,        last_name
,        department_id
    from source
)
select * from renamed
