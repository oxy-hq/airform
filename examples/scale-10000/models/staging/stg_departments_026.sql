with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        cost_center
,        department_name
,        budget
,        parent_id
    from source
)
select * from renamed
