with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        end_date
,        status
,        goal
,        start_date
,        spend
,        channel
,        budget
    from source
)
select * from renamed
