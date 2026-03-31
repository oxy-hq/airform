with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        manager_id
,        first_name
,        hire_date
,        email
,        salary
,        last_name
    from source
)
select * from renamed
