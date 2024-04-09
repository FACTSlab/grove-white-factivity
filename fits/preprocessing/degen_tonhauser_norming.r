## Degen and Tonhauser's norming data
norming0 <- read.csv("projective-probability/results/1-prior/data/cd.csv")
norming <- subset(norming0,item!="F1" & item!="F2")
norming$context <- ""
norming[which(norming$fact=="Emily has been saving for a year"),]$context <- "8H"
norming[which(norming$fact=="Frank has always wanted a pet"),]$context <- "12H"
norming[which(norming$fact=="Charley lives in Mexico"),]$context <- "20H"
norming[which(norming$fact=="Jon lives 10 miles away from work"),]$context <- "19L"
norming[which(norming$fact=="Mia is a college student"),]$context <- "6H"
norming[which(norming$fact=="Julian is Cuban"),]$context <- "18H"
norming[which(norming$fact=="Tony has been sober for 20 years"),]$context <- "15L"
norming[which(norming$fact=="Jackson is training for a marathon"),]$context <- "13H"
norming[which(norming$fact=="Emma is in first grade"),]$context <- "3L"
norming[which(norming$fact=="Josie doesn&quotechart have a passport"),]$context <- "2L"
norming[which(norming$fact=="Danny is a diabetic"),]$context <- "11L"
norming[which(norming$fact=="Olivia has two small children"),]$context <- "4L"
norming[which(norming$fact=="Mary is taking a prenatal yoga class"),]$context <- "1H"
norming[which(norming$fact=="Jayden doesn&quotechart have a driver&quotechars license"),]$context <- "14L"
norming[which(norming$fact=="Owen lives in New Orleans"),]$context <- "17L"
norming[which(norming$fact=="Grace hates her sister"),]$context <- "9L"
norming[which(norming$fact=="Josh is a 5-year old boy"),]$context <- "16H"
norming[which(norming$fact=="Zoe is a math major"),]$context <- "10H"
norming[which(norming$fact=="Isabella is a vegetarian"),]$context <- "7L"
norming[which(norming$fact=="Sophia is a hipster"),]$context <- "5H"
norming[which(norming$fact=="Owen lives in Chicago"),]$context <- "17H"
norming[which(norming$fact=="Jayden&quotechars car is in the shop"),]$context <- "14H"
norming[which(norming$fact=="Emily never has any money"),]$context <- "8L"
norming[which(norming$fact=="Isabella is from Argentina"),]$context <- "7H"
norming[which(norming$fact=="Josie loves France"),]$context <- "2H"
norming[which(norming$fact=="Jackson is obese"),]$context <- "13L"
norming[which(norming$fact=="Charley lives in Korea"),]$context <- "20L"
norming[which(norming$fact=="Frank is allergic to cats"),]$context <- "12L"
norming[which(norming$fact=="Danny loves cake"),]$context <- "11H"
norming[which(norming$fact=="Mia is a nun"),]$context <- "6L"
norming[which(norming$fact=="Josh is a 75-year old man"),]$context <- "16L"
norming[which(norming$fact=="Julian is German"),]$context <- "18L"
norming[which(norming$fact=="Emma is in law school"),]$context <- "3H"
norming[which(norming$fact=="Tony really likes to party with his friends"),]$context <- "15H"
norming[which(norming$fact=="Grace loves her sister"),]$context <- "9H"
norming[which(norming$fact=="Zoe is 5 years old"),]$context <- "10L"
norming[which(norming$fact=="Mary is a middle school student"),]$context <- "1L"
norming[which(norming$fact=="Sophia is a high end fashion model"),]$context <- "5L"
norming[which(norming$fact=="Jon lives 2 blocks away from work"),]$context <- "19H"
norming[which(norming$fact=="Olivia works the third shift"),]$context <- "4H"
norming$context_number <- 0
norming[which(norming$fact=="Emily has been saving for a year."),]$context_number <- 1
norming[which(norming$fact=="Frank has always wanted a pet."),]$context_number <- 2
norming[which(norming$fact=="Charley lives in Mexico."),]$context_number <- 3
norming[which(norming$fact=="Jon lives 10 miles away from work."),]$context_number <- 4
norming[which(norming$fact=="Mia is a college student."),]$context_number <- 5
norming[which(norming$fact=="Julian is Cuban."),]$context_number <- 6
norming[which(norming$fact=="Tony has been sober for 20 years."),]$context_number <- 7
norming[which(norming$fact=="Jackson is training for a marathon."),]$context_number <- 8
norming[which(norming$fact=="Emma is in first grade."),]$context_number <- 9
norming[which(norming$fact=="Josie doesn&quotechart have a passport."),]$context_number <- 10
norming[which(norming$fact=="Danny is a diabetic."),]$context_number <- 11
norming[which(norming$fact=="Olivia has two small children."),]$context_number <- 12
norming[which(norming$fact=="Mary is taking a prenatal yoga class."),]$context_number <- 13
norming[which(norming$fact=="Jayden doesn&quotechart have a driver&quotechars license."),]$context_number <- 14
norming[which(norming$fact=="Owen lives in New Orleans."),]$context_number <- 15
norming[which(norming$fact=="Grace hates her sister."),]$context_number <- 16
norming[which(norming$fact=="Josh is a 5-year old boy."),]$context_number <- 17
norming[which(norming$fact=="Zoe is a math major."),]$context_number <- 18
norming[which(norming$fact=="Isabella is a vegetarian."),]$context_number <- 19
norming[which(norming$fact=="Sophia is a hipster."),]$context_number <- 20
norming[which(norming$fact=="Owen lives in Chicago."),]$context_number <- 21
norming[which(norming$fact=="Jayden&quotechars car is in the shop."),]$context_number <- 22
norming[which(norming$fact=="Emily never has any money."),]$context_number <- 23
norming[which(norming$fact=="Isabella is from Argentina."),]$context_number <- 24
norming[which(norming$fact=="Josie loves France."),]$context_number <- 25
norming[which(norming$fact=="Jackson is obese."),]$context_number <- 26
norming[which(norming$fact=="Charley lives in Korea."),]$context_number <- 27
norming[which(norming$fact=="Frank is allergic to cats."),]$context_number <- 28
norming[which(norming$fact=="Danny loves cake."),]$context_number <- 29
norming[which(norming$fact=="Mia is a nun."),]$context_number <- 30
norming[which(norming$fact=="Josh is a 75-year old man."),]$context_number <- 31
norming[which(norming$fact=="Julian is German."),]$context_number <- 32
norming[which(norming$fact=="Emma is in law school."),]$context_number <- 33
norming[which(norming$fact=="Tony really likes to party with his friends."),]$context_number <- 34
norming[which(norming$fact=="Grace loves her sister."),]$context_number <- 35
norming[which(norming$fact=="Zoe is 5 years old."),]$context_number <- 36
norming[which(norming$fact=="Mary is a middle school student."),]$context_number <- 37
norming[which(norming$fact=="Sophia is a high end fashion model."),]$context_number <- 38
norming[which(norming$fact=="Jon lives 2 blocks away from work."),]$context_number <- 39
norming[which(norming$fact=="Olivia works the third shift."),]$context_number <- 40
norming$participant <- as.numeric(as.factor(norming$workerid))
norming <- norming[c("participant","context","context_number","response")]
