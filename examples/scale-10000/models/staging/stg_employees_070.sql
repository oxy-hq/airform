with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        department_id
,        hire_date
,        manager_id
    from source
)
select * from renamed
