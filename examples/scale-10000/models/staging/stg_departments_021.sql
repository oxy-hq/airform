with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        created_at
,        cost_center
,        parent_id
,        department_name
,        region
,        budget
    from source
)
select * from renamed
