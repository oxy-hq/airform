with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        spend
,        start_date
,        goal
,        end_date
,        channel
    from source
)
select * from renamed
