with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        hire_date
,        last_name
,        salary
,        first_name
,        email
,        manager_id
,        title
    from source
)
select * from renamed
