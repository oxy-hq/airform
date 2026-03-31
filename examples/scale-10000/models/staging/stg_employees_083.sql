with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        first_name
,        hire_date
,        salary
,        manager_id
,        email
    from source
)
select * from renamed
