with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        salary
,        title
,        last_name
,        status
,        hire_date
    from source
)
select * from renamed
