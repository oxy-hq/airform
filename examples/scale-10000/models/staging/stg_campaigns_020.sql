with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        channel
,        target_audience
,        end_date
    from source
)
select * from renamed
