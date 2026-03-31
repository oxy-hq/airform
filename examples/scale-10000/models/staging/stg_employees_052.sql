with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        hire_date
,        manager_id
,        department_id
    from source
)
select * from renamed
