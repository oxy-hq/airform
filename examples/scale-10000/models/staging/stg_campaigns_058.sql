with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        spend
,        goal
,        campaign_name
,        target_audience
    from source
)
select * from renamed
