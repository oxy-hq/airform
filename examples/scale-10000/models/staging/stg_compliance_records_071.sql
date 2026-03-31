with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        created_at
,        risk_level
,        reviewed_at
,        reviewer_id
,        record_type
,        status
,        category
    from source
)
select * from renamed
