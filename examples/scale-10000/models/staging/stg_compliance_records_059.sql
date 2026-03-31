with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        created_at
,        account_id
,        reviewed_at
,        risk_level
,        category
,        status
,        record_type
    from source
)
select * from renamed
