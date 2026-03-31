with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        spend
,        goal
,        start_date
,        campaign_name
,        target_audience
,        budget
    from source
)
select * from renamed
