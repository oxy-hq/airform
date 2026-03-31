with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        last_name
,        manager_id
,        hire_date
,        salary
,        status
    from source
)
select * from renamed
