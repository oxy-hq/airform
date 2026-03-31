with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        channel
,        spend
,        start_date
,        budget
,        end_date
,        goal
    from source
)
select * from renamed
