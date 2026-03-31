with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        reviewed_at
,        created_at
,        risk_level
,        category
,        notes
,        account_id
    from source
)
select * from renamed
