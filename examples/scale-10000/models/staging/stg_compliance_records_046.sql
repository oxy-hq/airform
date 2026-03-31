with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        status
,        created_at
,        reviewed_at
,        category
,        account_id
,        notes
    from source
)
select * from renamed
