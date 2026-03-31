with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        hire_date
,        salary
,        title
,        email
,        status
    from source
)
select * from renamed
