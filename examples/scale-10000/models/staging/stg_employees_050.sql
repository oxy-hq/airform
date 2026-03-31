with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        first_name
,        last_name
,        title
,        hire_date
,        salary
    from source
)
select * from renamed
