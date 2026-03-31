with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        goal
,        end_date
,        spend
,        campaign_name
,        status
,        channel
,        budget
    from source
)
select * from renamed
