with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        status
,        created_at
,        account_id
,        category
,        risk_level
,        reviewed_at
    from source
)
select * from renamed
