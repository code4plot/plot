group = c()
t = c()
res = c()
biom = c()

biomarker = c("a","b","c","d")

for(i in biomarker){
  for(n in seq(0,5)){
    #treat
    res = append(res,rnorm(10,runif(1,50,55), sd = runif(1,0.5,2)))
    #control
    res = append(res,rnorm(10,runif(1,50,51), sd = runif(1,0.5,2)))
    group = append(group,rep(c("treatment","control"),each = 10))
    t = append(t,rep(as.character(n),20))
    biom = append(biom,rep(i,20))
  }
}

df <- data.frame(biom = biom, group = group, time = t, readout = res)
for(i in biomarker){
  subdf <- subset(df, biom == i)  
  fit <- lm(readout ~ group:time, data = subdf)
  print(summary(fit))
  
}

subdf <- subset(df, biom == "b")

s = ggplot(subdf,aes(x = time, y = readout, color = group, group = group)) +
  geom_point() + 
  geom_smooth()
s
