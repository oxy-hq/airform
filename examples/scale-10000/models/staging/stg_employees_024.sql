with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        hire_date
,        manager_id
,        last_name
,        email
,        first_name
    from source
)
select * from renamed
