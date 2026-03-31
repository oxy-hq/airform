with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        end_date
,        status
,        campaign_name
,        target_audience
,        channel
,        start_date
    from source
)
select * from renamed
