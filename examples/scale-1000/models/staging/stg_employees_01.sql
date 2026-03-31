with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        salary
,        email
,        title
    from source
)

select * from renamed
