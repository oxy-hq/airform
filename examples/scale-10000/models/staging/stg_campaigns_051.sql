with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        channel
,        campaign_name
,        goal
,        start_date
,        end_date
    from source
)
select * from renamed
