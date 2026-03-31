with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        head_count
,        location
,        department_name
,        region
,        created_at
,        cost_center
    from source
)
select * from renamed
