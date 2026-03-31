with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        account_id
,        status
,        reviewed_at
,        record_type
,        reviewer_id
    from source
)
select * from renamed
