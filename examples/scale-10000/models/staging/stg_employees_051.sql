with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        salary
,        hire_date
,        email
,        first_name
,        last_name
    from source
)
select * from renamed
