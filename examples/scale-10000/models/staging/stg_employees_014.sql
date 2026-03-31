with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        status
,        title
,        email
,        salary
,        hire_date
,        manager_id
    from source
)
select * from renamed
