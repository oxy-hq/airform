with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        channel
,        budget
,        start_date
,        end_date
,        status
,        target_audience
,        campaign_name
    from source
)
select * from renamed
