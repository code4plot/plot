library(curl)
h <- new_handle()
handle_setheaders(h, "AccessKey" = "8da3d5f8-fa26-421a-95c5-58d2095cff84")
t<- curl(url = "https://www.ura.gov.sg/uraDataService/insertNewToken.action", handle = h)

write(readLines(t), file = "token.txt")
