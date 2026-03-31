with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        salary
,        last_name
,        title
,        email
,        hire_date
,        status
    from source
)
select * from renamed
