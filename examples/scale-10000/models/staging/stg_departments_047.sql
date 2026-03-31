with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        region
,        department_name
,        created_at
,        cost_center
,        location
,        status
,        head_count
    from source
)
select * from renamed
