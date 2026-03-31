with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        created_at
,        risk_level
,        status
,        record_type
,        reviewed_at
,        category
    from source
)
select * from renamed
