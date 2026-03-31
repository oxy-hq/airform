with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        cost_center
,        location
,        department_name
    from source
)
select * from renamed
