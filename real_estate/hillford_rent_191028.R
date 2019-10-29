library(ggplot2)

#choose condo project to visualize
projectName = "THE HILLFORD"

#load raw data
rawDat = "rawDat_191028.csv"
rawDat = read.csv(rawDat, stringsAsFactors = F)

#subset to analyze condominiums and executive condominiums
condo = subset(rawDat, propertyType %in% c("Non-landed Properties", "Executive Condominium"))


District = condo$district[which(condo$project == projectName)][1]
#plot S$ per square feet (psf)
s = ggplot(subset(condo, district == District), aes(x = as.factor(leaseDate), y = psf, group = 1)) + 
	stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
	stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
	stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
	geom_jitter(data = subset(condo, project == projectName), aes(color = as.factor(noOfBedRoom)), position = position_jitter(0.2), size = 2) +
	labs(y = "S$ per square feet", x = "Lease Date (Quarterly)", color = "# Bed Room") +
	ggtitle("Rental Stats @ THE HILLFORD") +
	theme_bw() + 
	theme(plot.title = element_text(size = 20, hjust = 0.5))
dev.new(width = 20, height = 12, unit = "cm")
s
#ggsave("hillford_rent.png", width = dev.size("cm")[1], height = dev.size("cm")[2], units = "cm")

#plot rent per month
t = ggplot(subset(condo, district == District), aes(x = as.factor(leaseDate), y = rent, group = 1)) + 
	stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
	stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
	stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
	geom_jitter(data = subset(condo, project == projectName), aes(color = as.factor(noOfBedRoom)), position = position_jitter(0.2), size = 2) +
	labs(y = "S$ per month", x = "Lease Date (Quarterly)", color = "# Bed Room") +
	ggtitle("Rental Stats @ THE HILLFORD") +
	theme_bw() + 
	theme(plot.title = element_text(size = 20, hjust = 0.5))
dev.new(width = 20, height = 12, unit = "cm")
t
#ggsave("hillford_rent2.png", width = dev.size("cm")[1], height = dev.size("cm")[2], units = "cm")

