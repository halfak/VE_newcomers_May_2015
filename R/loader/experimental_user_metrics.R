source("env.R")
source("util.R")

load.experimental_user_metrics = tsv_loader(
	paste(DATA_DIR, "experimental_user_metrics.tsv", sep="/"),
	"EXPERIMENTAL_USER_METRICS",
    function(df){
        df$user_registration <- NULL
        df
    }
)
