source("loader/experimental_users.R")
source("loader/experimental_user_metrics.R")
source("loader/experimental_user_editing_sessions.R")


users = load.experimental_users(reload=T)
metrics = load.experimental_user_metrics(reload=T)

user_metrics = merge(users, metrics, by="user_id")

user_metrics$editing = user_metrics$day_revisions > 0
user_metrics$week_editing = user_metrics$week_revisions > 0
user_metrics$main_editing = user_metrics$day_main_revisions > 0
user_metrics$week_main_editing = user_metrics$week_main_revisions > 0
user_metrics$talk_editing = user_metrics$day_talk_revisions > 0
user_metrics$week_talk_editing = user_metrics$week_talk_revisions > 0
user_metrics$user_editing = user_metrics$day_user_revisions > 0
user_metrics$week_user_editing = user_metrics$week_user_revisions > 0
user_metrics$wp_editing = user_metrics$day_wp_revisions > 0
user_metrics$week_wp_editing = user_metrics$week_wp_revisions > 0
user_metrics$productive = user_metrics$day_main_revisions >
                          user_metrics$day_reverted_main_revisions
user_metrics$week_productive = user_metrics$week_main_revisions >
                               user_metrics$week_reverted_main_revisions
user_metrics$gt_one_hour = user_metrics$time_spent_editing > 60*60

wiki.table(
user_metrics[,
    list(
        editing.k = sum(editing),
        week_editing.k = sum(week_editing),
        main_editing.k = sum(main_editing),
        week_main_editing.k = sum(week_main_editing),
        talk_editing.k = sum(talk_editing),
        week_talk_editing.k = sum(week_talk_editing),
        user_editing.k = sum(user_editing),
        week_user_editing.k = sum(week_user_editing),
        wp_editing.k = sum(wp_editing),
        week_wp_editing.k = sum(week_wp_editing),
        productive.k = sum(productive),
        week_productive.k = sum(week_productive),
        surviving.k = sum(surviving == "True"),
        gt_one_hour.k = sum(gt_one_hour),
        enabled.k = sum(ve_enabled),
        n = length(user_id)
    ),
    list(
        bucket,
        via_mobile
    )
]
)

user_metrics$day_productive_edits = with(
    user_metrics,
    day_main_revisions - day_reverted_main_revisions
)
user_metrics$week_productive_edits = with(
    user_metrics,
    week_main_revisions - week_reverted_main_revisions
)

with(
    user_metrics,
    wilcox.test(
        day_productive_edits[bucket == "control"],
        day_productive_edits[bucket == "experimental"]
    )
)
with(
    user_metrics,
    wilcox.test(
        week_productive_edits[bucket == "control"],
        week_productive_edits[bucket == "experimental"]
    )
)


edit_session = load.experimental_user_editing_sessions(reload=T)

user_ve_edits = merge(
    users[,list(user_id),],
    edit_sessions[outcome == "success",
        list(
            ve_edits = length(outcome)
        ),
        user_id
    ],
    by="user_id",
    all=T
)[,list(user_id, ve_edits = if.na(ve_edits, 0))]


user_metrics = merge(
    users,
    merge(user_ve_edits, metrics, by="user_id"),
    by="user_id"
)
user_metrics$prop.ve = user_metrics$ve_edits /
                       pmax(user_metrics$week_revisions, 1)
user_metrics$primarily.ve = user_metrics$prop.ve > 0.5

svg("productivity/plots/productive_edit_density.by_primary_editor.svg",
    height=5,
    width=8)
ggplot(
    rbind(
        with(
            user_metrics[bucket=="experimental" & week_revisions > 0,],
            data.table(
                group="all",
                productive_edits = week_main_revisions -
                                   week_reverted_main_revisions
            )
        ),
        with(
            user_metrics[bucket=="experimental" & week_revisions > 0 &
                         prop.ve >= 0.5,],
            data.table(
                group="mostly VE",
                productive_edits = week_main_revisions -
                                   week_reverted_main_revisions
            )
        ),
        with(
            user_metrics[bucket=="experimental" & week_revisions > 0 &
                         prop.ve < 0.5,],
            data.table(
                group="mostly Wikitext",
                productive_edits = week_main_revisions -
                                   week_reverted_main_revisions
            )
        )
    ),
    aes(x=productive_edits+1, group=group, fill=group)
) +
theme_bw() +
geom_density(adjust=3, alpha=0.4) +
scale_x_log10(
    "Productive edits",
    breaks=c(0, 1, 5, 10, 50, 100)+1,
    labels=c(0, 1, 5, 10, 50, 100)
)
dev.off()

user_metrics[
    bucket == "experimental",
    list(
        productive = sum(week_main_revisions - week_reverted_main_revisions > 0),
        editing = sum(week_revisions > 0),
        n = length(user_id)
    ),
    list(
        group = if.then(prop.ve < 0.5, "mostly WT", "mostly VE")
    )
]
