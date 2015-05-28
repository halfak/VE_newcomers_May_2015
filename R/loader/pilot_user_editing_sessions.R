source("env.R")
source("util.R")

load.pilot_user_editing_sessions = tsv_loader(
	paste(DATA_DIR, "pilot_user_editing_sessions.tsv", sep="/"),
	"PILOT_USER_EDITING_SESSIONS",
    function(df){
        df$registration = as.POSIXct(
            as.character(df$registration),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
    }
)
