 type <- "f1"
 topic <- "206"
 test_data <- read.table(sprintf("/Users/wwwjscom/Research/Enron-Email-Features-exp/code/results.keep/summary_for_%s_%s.txt", topic, type), header=T, sep=",")
 plot_colors <- c("blue","red","forestgreen", "orange")

 ylim <- max(test_data)

 png(filename=sprintf("/Users/wwwjscom/Research/Enron-Email-Features-exp/code/results.keep/graphs/%s/%s_%s.png",type, topic,type), height=500, width=1000, bg="white")

 
 plot(test_data$a, type="o", col=plot_colors[1], ylim=c(0,20), xlim=c(1,33))
 box()
 lines(test_data$b, type="o", pch=22, lty=2, col=plot_colors[2])
 lines(test_data$c, type="o", pch=23, lty=3, col=plot_colors[3])
 lines(test_data$d, type="o", pch=24, lty=4, col=plot_colors[4])
 title(main=paste(type, "score for topic", topic), col.main="red", font.main=4)
dev.off()