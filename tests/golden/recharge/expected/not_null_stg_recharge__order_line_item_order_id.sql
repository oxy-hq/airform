select order_id
from "recharge"."main_recharge_source"."stg_recharge__order_line_item"
where order_id is null
