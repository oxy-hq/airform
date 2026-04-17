with report as (

    select *
    from youtube__video_report

), fields as (

    select
        video_published_at as created_timestamp,
        cast(video_id as TEXT) as post_id,
        cast(video_description as TEXT) as post_message,
        cast(default_thumbnail_url as TEXT) as post_url,
        cast(channel_id as TEXT) as page_id,
        cast(channel_title as TEXT) as page_name,
        source_relation,
        'youtube' as platform,
        coalesce(sum(views),0) as clicks,
        coalesce(sum(comments),0) as comments,
        coalesce(sum(likes),0) as likes,
        coalesce(sum(shares),0) as shares
    from report
    group by 1,2,3,4,5,6,7,8

)

select *
from fields
