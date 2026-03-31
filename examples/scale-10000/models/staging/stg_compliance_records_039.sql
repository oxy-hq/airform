with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        risk_level
,        created_at
,        category
,        account_id
,        status
    from source
)
select * from renamed
