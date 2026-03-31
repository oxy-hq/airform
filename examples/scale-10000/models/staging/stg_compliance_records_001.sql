with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        notes
,        risk_level
,        created_at
    from source
)
select * from renamed
