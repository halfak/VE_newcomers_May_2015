source("env.R")
source("util.R")

load.pilot_user_metrics = tsv_loader(
	paste(DATA_DIR, "pilot_user_metrics.tsv", sep="/"),
	"PILOT_USER_METRICS",
    function(df){
        df$user_registration <- NULL
        df
    }
)
