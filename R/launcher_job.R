launcher_job <- function(x, cluster_name = "Kubernetes", 
                         job_name = "scripted_job",
                         image = "rstudio/r-session-complete:centos7-1.2.1320-1-r-3.5.3") {
  .rs.api.launcher.submitJob(
    name = job_name,
    cluster = c(cluster_name),
    command = "R",
    args = c("--slave", "--no-save", "--no-restore") ,
    stdin = x,
    container = .rs.api.launcher.newContainer(image)
  )
}
