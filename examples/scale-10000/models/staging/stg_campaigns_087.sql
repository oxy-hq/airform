with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        goal
,        channel
,        target_audience
,        campaign_name
,        spend
,        end_date
    from source
)
select * from renamed
