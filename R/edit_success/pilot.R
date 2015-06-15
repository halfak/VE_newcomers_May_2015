source("loader/pilot_users.R")
source("loader/pilot_user_metrics.R")
source("loader/pilot_user_editing_sessions.R")

library(plyr)

users = load.pilot_users(reload=T)
metrics = load.pilot_user_metrics(reload=T)
edit_sessions = load.pilot_user_editing_sessions(reload=T)

ve_sessions = nrow(edit_sessions[editor == "visualeditor"])
resampled_edit_sessions = rbind(
    edit_sessions[editor == "wikitext",],
    edit_sessions[editor == "visualeditor"][
        sample(ve_sessions, ve_sessions/4)
    ]
)
user_edit_sessions = merge(users, resampled_edit_sessions, by="user_id")
user_edit_sessions[,
    list(
        count = length(user_id)
    ),
    list(bucket)
]

user_edit_sessions[bucket=="experimental",
    list(
        count = length(bucket)
    ),
    list(user_id)
][order(count, decreasing=T)][1:10]

user_edit_sessions[bucket=="control",
    list(
        count = length(bucket)
    ),
    list(user_id)
][order(count, decreasing=T)][1:10]

first_5_sessions = ddply(
    user_edit_sessions,
    .(user_id),
    function(sub_dt){
        sub_dt[order(sub_dt$session_started),][1:min(5, nrow(sub_dt)),]
    }
)
first_5_sessions = data.table(first_5_sessions)
first_5_sessions[,
    list(
        count = length(user_id)
    ),
    list(bucket)
]



first_5_sessions[,
    list(
        users.n = length(unique(user_id)),
        ve.k = sum(editor == "visualeditor"),
        ve.p = sum(editor == "visualeditor")/length(session_id),
        attempted.k = sum(outcome == "success" | !is.na(first_attempt)),
        attempted.p = sum(outcome == "success" | !is.na(first_attempt))/length(session_id),
        successful.k = sum(outcome == "success"),
        successful.p = sum(outcome == "success")/length(session_id),
        changed_and_noswitch.n = sum(outcome != "abort_nochange" & outcome != "switch_editors"),
        changed.n = sum(outcome != "abort_nochange"),
        n = length(session_id)
    ),
    list(bucket, via_mobile)
]


user_session_count = resampled_edit_sessions[,
    list(editing_sessions = length(session_id)),
    user_id
]
merge(
    users,
    merge(metrics, user_session_count, by="user_id", all=T),
    by="user_id"
)[,
    list(
        has_editing_sessions.k = sum(!is.na(editing_sessions) | day_revisions > 0),
        editing.n = sum(day_revisions > 0)
    ),
    list(bucket, via_mobile)
]
