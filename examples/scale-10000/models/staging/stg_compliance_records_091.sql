with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        category
,        account_id
,        record_type
,        reviewed_at
,        risk_level
,        notes
    from source
)
select * from renamed
