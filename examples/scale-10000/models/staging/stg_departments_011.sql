with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        created_at
,        department_name
,        cost_center
,        head_count
,        region
    from source
)
select * from renamed
