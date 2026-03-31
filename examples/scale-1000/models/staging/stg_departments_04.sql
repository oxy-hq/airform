with source as (
    select * from {{ source('raw', 'raw_departments') }}
),

renamed as (
    select
        id as department_id
,        status
,        parent_id
,        region
,        cost_center
    from source
)

select * from renamed
