with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        cost_center
,        head_count
,        parent_id
,        department_name
,        location
    from source
)
select * from renamed
