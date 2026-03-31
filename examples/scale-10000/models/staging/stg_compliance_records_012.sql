with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        account_id
,        category
,        reviewed_at
,        notes
,        status
    from source
)
select * from renamed
