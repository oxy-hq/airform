with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        salary
,        first_name
,        manager_id
,        status
,        hire_date
,        title
    from source
)
select * from renamed
