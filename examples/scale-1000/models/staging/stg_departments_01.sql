with source as (
    select * from {{ source('raw', 'raw_departments') }}
),

renamed as (
    select
        id as department_id
,        head_count
,        status
,        parent_id
,        cost_center
,        created_at
    from source
)

select * from renamed
