source("loader/experimental_users.R")
source("loader/experimental_user_metrics.R")
source("loader/experimental_user_editing_sessions.R")


users = load.experimental_users(reload=T)
metrics = load.experimental_user_metrics(reload=T)

user_metrics = merge(users, metrics, by="user_id")

user_metrics$week_productive_edits = with(
    user_metrics,
    week_main_revisions - week_reverted_main_revisions
)

user_metrics$editing = user_metrics$day_revisions > 0
user_metrics$week_editing = user_metrics$week_revisions > 0
user_metrics$main_editing = user_metrics$day_main_revisions > 0
user_metrics$week_main_editing = user_metrics$week_main_revisions > 0
user_metrics$productive = user_metrics$day_main_revisions >
                          user_metrics$day_reverted_main_revisions
user_metrics$week_productive = user_metrics$week_productive_edits > 0
user_metrics$gt_one_hour = user_metrics$time_spent_editing > 60*60


bucket_metrics = user_metrics[via_mobile == 0,
    list(
        editing.k = sum(week_editing),
        editing.p = sum(week_editing)/length(user_id),
        main_editing.k = sum(week_main_editing),
        main_editing.p = sum(week_main_editing)/length(user_id),
        productive.k = sum(week_productive),
        productive.p = sum(week_productive)/length(user_id),
        surviving.k = sum(surviving == "True"),
        surviving.p = sum(surviving == "True")/length(user_id),
        gt_one_hour.k = sum(gt_one_hour),
        gt_one_hour.p = sum(gt_one_hour)/length(user_id),
        ve_enabled.k = sum(ve_enabled),
        ve_enabled.k = sum(ve_enabled)/length(user_id),
        n = length(user_id)
    ),
    list(
        bucket,
        via_mobile
    )
]
wiki.table(bucket_metrics)

with(
    bucket_metrics,
    prop.test(editing.k, n)
)
with(
    user_metrics,
    wilcox.test(
        week_revisions[bucket == "control"],
        week_revisions[bucket == "experimental"]
    )
)

with(
    bucket_metrics,
    prop.test(main_editing.k, n)
)
with(
    user_metrics,
    wilcox.test(
        week_main_revisions[bucket == "control"],
        week_main_revisions[bucket == "experimental"]
    )
)

with(
    bucket_metrics,
    prop.test(productive.k, n)
)
with(
    user_metrics,
    wilcox.test(
        week_productive_edits[bucket == "control"],
        week_productive_edits[bucket == "experimental"]
    )
)

with(
    bucket_metrics,
    prop.test(gt_one_hour.k, n)
)
with(
    user_metrics,
    wilcox.test(
        time_spent_editing[bucket == "control"],
        time_spent_editing[bucket == "experimental"]
    )
)

with(
    bucket_metrics,
    prop.test(surviving.k, n)
)
