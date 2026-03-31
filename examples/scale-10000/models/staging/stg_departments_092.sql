with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        department_name
,        location
,        budget
,        parent_id
,        created_at
,        cost_center
    from source
)
select * from renamed
