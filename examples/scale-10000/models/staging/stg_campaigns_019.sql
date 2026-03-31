with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        start_date
,        spend
,        goal
,        end_date
    from source
)
select * from renamed
