with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        salary
,        email
,        manager_id
,        status
,        title
,        hire_date
    from source
)
select * from renamed
