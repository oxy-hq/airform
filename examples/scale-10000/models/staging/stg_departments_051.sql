with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        cost_center
,        region
,        parent_id
,        status
,        department_name
,        budget
,        location
    from source
)
select * from renamed
