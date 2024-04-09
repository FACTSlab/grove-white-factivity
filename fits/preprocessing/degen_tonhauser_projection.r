## Degen and Tonhauser's projection data
projection0 <- read.csv("projective-probability/results/3-projectivity/data/cd.csv")
projection <- subset(projection0,trigger_class!="control")
projection$item <- paste(projection$verb,projection$fact,sep="_")
projection$predicate <- projection$verb
projection[which(projection$predicate=="annoyed"),]$predicate <- "be annoyed"
projection[which(projection$predicate=="be_right_that"),]$predicate <- "be right"
projection[which(projection$predicate=="inform_Sam"),]$predicate <- "inform"
projection$predicate_number <- 0
projection[which(projection$predicate=="establish"),]$predicate_number <- 1
projection[which(projection$predicate=="prove"),]$predicate_number <- 2
projection[which(projection$predicate=="reveal"),]$predicate_number <- 3
projection[which(projection$predicate=="confirm"),]$predicate_number <- 4
projection[which(projection$predicate=="acknowledge"),]$predicate_number <- 5
projection[which(projection$predicate=="be right"),]$predicate_number <- 6
projection[which(projection$predicate=="think"),]$predicate_number <- 7
projection[which(projection$predicate=="say"),]$predicate_number <- 8
projection[which(projection$predicate=="be annoyed"),]$predicate_number <- 9
projection[which(projection$predicate=="announce"),]$predicate_number <- 10
projection[which(projection$predicate=="know"),]$predicate_number <- 11
projection[which(projection$predicate=="inform"),]$predicate_number <- 12
projection[which(projection$predicate=="admit"),]$predicate_number <- 13
projection[which(projection$predicate=="discover"),]$predicate_number <- 14
projection[which(projection$predicate=="pretend"),]$predicate_number <- 15
projection[which(projection$predicate=="hear"),]$predicate_number <- 16
projection[which(projection$predicate=="suggest"),]$predicate_number <- 17
projection[which(projection$predicate=="demonstrate"),]$predicate_number <- 18
projection[which(projection$predicate=="see"),]$predicate_number <- 19
projection[which(projection$predicate=="confess"),]$predicate_number <- 20
projection$context <- ""
projection[which(projection$fact=="Emily has been saving for a year"),]$context <- "8H"
projection[which(projection$fact=="Frank has always wanted a pet"),]$context <- "12H"
projection[which(projection$fact=="Charley lives in Mexico"),]$context <- "20H"
projection[which(projection$fact=="Jon lives 10 miles away from work"),]$context <- "19L"
projection[which(projection$fact=="Mia is a college student"),]$context <- "6H"
projection[which(projection$fact=="Julian is Cuban"),]$context <- "18H"
projection[which(projection$fact=="Tony has been sober for 20 years"),]$context <- "15L"
projection[which(projection$fact=="Jackson is training for a marathon"),]$context <- "13H"
projection[which(projection$fact=="Emma is in first grade"),]$context <- "3L"
projection[which(projection$fact=="Josie doesn&quotechart have a passport"),]$context <- "2L"
projection[which(projection$fact=="Danny is a diabetic"),]$context <- "11L"
projection[which(projection$fact=="Olivia has two small children"),]$context <- "4L"
projection[which(projection$fact=="Mary is taking a prenatal yoga class"),]$context <- "1H"
projection[which(projection$fact=="Jayden doesn&quotechart have a driver&quotechars license"),]$context <- "14L"
projection[which(projection$fact=="Owen lives in New Orleans"),]$context <- "17L"
projection[which(projection$fact=="Grace hates her sister"),]$context <- "9L"
projection[which(projection$fact=="Josh is a 5-year old boy"),]$context <- "16H"
projection[which(projection$fact=="Zoe is a math major"),]$context <- "10H"
projection[which(projection$fact=="Isabella is a vegetarian"),]$context <- "7L"
projection[which(projection$fact=="Sophia is a hipster"),]$context <- "5H"
projection[which(projection$fact=="Owen lives in Chicago"),]$context <- "17H"
projection[which(projection$fact=="Jayden&quotechars car is in the shop"),]$context <- "14H"
projection[which(projection$fact=="Emily never has any money"),]$context <- "8L"
projection[which(projection$fact=="Isabella is from Argentina"),]$context <- "7H"
projection[which(projection$fact=="Josie loves France"),]$context <- "2H"
projection[which(projection$fact=="Jackson is obese"),]$context <- "13L"
projection[which(projection$fact=="Charley lives in Korea"),]$context <- "20L"
projection[which(projection$fact=="Frank is allergic to cats"),]$context <- "12L"
projection[which(projection$fact=="Danny loves cake"),]$context <- "11H"
projection[which(projection$fact=="Mia is a nun"),]$context <- "6L"
projection[which(projection$fact=="Josh is a 75-year old man"),]$context <- "16L"
projection[which(projection$fact=="Julian is German"),]$context <- "18L"
projection[which(projection$fact=="Emma is in law school"),]$context <- "3H"
projection[which(projection$fact=="Tony really likes to party with his friends"),]$context <- "15H"
projection[which(projection$fact=="Grace loves her sister"),]$context <- "9H"
projection[which(projection$fact=="Zoe is 5 years old"),]$context <- "10L"
projection[which(projection$fact=="Mary is a middle school student"),]$context <- "1L"
projection[which(projection$fact=="Sophia is a high end fashion model"),]$context <- "5L"
projection[which(projection$fact=="Jon lives 2 blocks away from work"),]$context <- "19H"
projection[which(projection$fact=="Olivia works the third shift"),]$context <- "4H"
projection$context_number <- 0
projection[which(projection$fact=="Emily has been saving for a year"),]$context_number <- 1
projection[which(projection$fact=="Frank has always wanted a pet"),]$context_number <- 2
projection[which(projection$fact=="Charley lives in Mexico"),]$context_number <- 3
projection[which(projection$fact=="Jon lives 10 miles away from work"),]$context_number <- 4
projection[which(projection$fact=="Mia is a college student"),]$context_number <- 5
projection[which(projection$fact=="Julian is Cuban"),]$context_number <- 6
projection[which(projection$fact=="Tony has been sober for 20 years"),]$context_number <- 7
projection[which(projection$fact=="Jackson is training for a marathon"),]$context_number <- 8
projection[which(projection$fact=="Emma is in first grade"),]$context_number <- 9
projection[which(projection$fact=="Josie doesn&quotechart have a passport"),]$context_number <- 10
projection[which(projection$fact=="Danny is a diabetic"),]$context_number <- 11
projection[which(projection$fact=="Olivia has two small children"),]$context_number <- 12
projection[which(projection$fact=="Mary is taking a prenatal yoga class"),]$context_number <- 13
projection[which(projection$fact=="Jayden doesn&quotechart have a driver&quotechars license"),]$context_number <- 14
projection[which(projection$fact=="Owen lives in New Orleans"),]$context_number <- 15
projection[which(projection$fact=="Grace hates her sister"),]$context_number <- 16
projection[which(projection$fact=="Josh is a 5-year old boy"),]$context_number <- 17
projection[which(projection$fact=="Zoe is a math major"),]$context_number <- 18
projection[which(projection$fact=="Isabella is a vegetarian"),]$context_number <- 19
projection[which(projection$fact=="Sophia is a hipster"),]$context_number <- 20
projection[which(projection$fact=="Owen lives in Chicago"),]$context_number <- 21
projection[which(projection$fact=="Jayden&quotechars car is in the shop"),]$context_number <- 22
projection[which(projection$fact=="Emily never has any money"),]$context_number <- 23
projection[which(projection$fact=="Isabella is from Argentina"),]$context_number <- 24
projection[which(projection$fact=="Josie loves France"),]$context_number <- 25
projection[which(projection$fact=="Jackson is obese"),]$context_number <- 26
projection[which(projection$fact=="Charley lives in Korea"),]$context_number <- 27
projection[which(projection$fact=="Frank is allergic to cats"),]$context_number <- 28
projection[which(projection$fact=="Danny loves cake"),]$context_number <- 29
projection[which(projection$fact=="Mia is a nun"),]$context_number <- 30
projection[which(projection$fact=="Josh is a 75-year old man"),]$context_number <- 31
projection[which(projection$fact=="Julian is German"),]$context_number <- 32
projection[which(projection$fact=="Emma is in law school"),]$context_number <- 33
projection[which(projection$fact=="Tony really likes to party with his friends"),]$context_number <- 34
projection[which(projection$fact=="Grace loves her sister"),]$context_number <- 35
projection[which(projection$fact=="Zoe is 5 years old"),]$context_number <- 36
projection[which(projection$fact=="Mary is a middle school student"),]$context_number <- 37
projection[which(projection$fact=="Sophia is a high end fashion model"),]$context_number <- 38
projection[which(projection$fact=="Jon lives 2 blocks away from work"),]$context_number <- 39
projection[which(projection$fact=="Olivia works the third shift"),]$context_number <- 40
projection$participant <- as.numeric(as.factor(projection$workerid))
projection <- projection[c("participant","predicate","predicate_number","context","context_number","response")]
