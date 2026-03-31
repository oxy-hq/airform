with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        hire_date
,        title
,        salary
,        status
,        email
,        first_name
    from source
)
select * from renamed
