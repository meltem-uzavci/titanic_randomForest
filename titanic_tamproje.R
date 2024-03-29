#test verisine bo� bir Survived kolonunun eklenmes�
titanic_test$Survived=NA 

#test ve e�itim setlerinin birle�tirilmesi
titanic_tamVeri=rbind(titanic_egitim,titanic_test) #test ve e�itim setlerinin birle�tirilmesi

#verinin genel g�r�n�m�ne bak�� atmak
str(titanic_tamVeri)


#veri t�rlerinin d�zenlenmesi

library(dplyr)
titanic_tamVeri = titanic_tamVeri %>% mutate(Survived=as.factor(Survived),
                                             Pclass=as.factor(Pclass),
                                             Sex=as.factor(Sex))


#verinin g�rselle�tirilmesi

library(ggplot2) 

grafik1=ggplot(titanic_tamVeri[1:891,]) + 
  geom_bar(mapping = aes(x = Pclass, fill = Survived)) + 
  theme(legend.position = "none")

grafik2=ggplot(titanic_tamVeri[1:891,]) + 
  geom_freqpoly(mapping = aes(x = Age, color = Survived), bins=50)

grafik3=ggplot(titanic_tamVeri[1:891,]) + 
  geom_freqpoly(mapping = aes(x = Fare, color = Survived), bins=50) + 
  theme(legend.position = "none")

grafik4=ggplot(titanic_tamVeri[1:891,]) + 
  geom_bar(mapping = aes(x = SibSp+Parch, fill = Survived), position = "fill") + 
  theme(legend.position = "none")


#birden fazla grafi�i ayn� ekranda g�stermemizi sa�layan paket

library(ggpubr)
ggarrange(grafik1,grafik2,grafik3,grafik4,ncol = 2, nrow = 2)



#bo� de�erleri tespit etmek
bos_deger=is.na(titanic_tamVeri$Age)

#bo� de�erlerin toplam say�s�n� bulmak i�in sum fonksiyonu kullan�l�r. 
sum(is.na(titanic_tamVeri$Age))

#t�m s�tunlardaki bo� de�erleri bulmak i�in apply fonksiyonunu kullanmam�z gerekir. 
apply(titanic_tamVeri, 2 , function(x) sum(is.na(x)))

#k�sa yoldan kay�p de�erleri g�rmek i�in;
summary(titanic_tamVeri)

#eksik de�erleri kald�rmak i�in;
titanic_bosyok=subset(titanic_tamVeri,Age!=is.na(Age))

#summary fonksiyonu ile bo� de�erler kald�r�ld�m� kontrol edelim.
summary(titanic_bosyok)

#eksik de�erleri kald�rman�n kolay yolu;yaln�zca say�lar� d�nd�r�r. 
titanic_bosyok2=na.omit(titanic_tamVeri$Age)

#veriyi daha ayr�nt�l� g�stermek i�in;
install.packages("psych")
library(psych)
describe(titanic_bosyok)


#hmisc paketi eksik ve tekil olan de�erleri g�rmek i�in kullan�labilir. 
install.packages("Hmisc")
library(Hmisc)
describe(titanic_bosyok)


#eksik de�erleri ortalama ile doldurmak

yas=titanic_tamVeri$Age #Age s�tununun yas de�i�kenine atanmas�

yas[is.na(yas)]=mean(yas,na.rm=TRUE) #bod de�erlere ortalama atanmas�

is.na(yas) #bos de�er kald�m� kontrol� yapal�m.

#olusturdugumuz yas de�i�keninin ger�ek verimize atanmas�

titanic_tamVeri$Age=yas


#ayk�r� de�erleri g�rmek i�in hmisc paketindeki describe fonksiyonunu kullanabiliriz.
describe(titanic_tamVeri$Age)

#~tespit etti�imiz ayk�r� de�erleri temizlemek i�in a�a��daki gibi subset fonksiyonu kullan�l�r. 
aykiri_temizlendi=subset(titanic_tamVeri,Age>1 & Age<70)

#e�itim ve test veri setlerine ay�rmak

egitim_son=titanic_tamVeri[1:891,]
test_son=titanic_tamVeri[892:1309,]


#randomforest algoritmas�- karar a�ac� algoritmas�d�r.�Stedi�imiz kadar fazla karar a�ac� olu�turulur ve bu karar a�a�lar�n�n ortalamas� al�narak tahminleme yap�l�r. 

install.packages("randomForest")
library(randomForest)


rf_model=randomForest(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare, 
                data = egitim_son, 
                mtry = 3, 
                ntree = 1000)


tahminler = predict(rf_model, test_son[, c(3,5,6,7,8,10)])

#yolcu numaras� sonu� de�i�kenine atand�.
sonuc=test_son$PassengerId


#sonuc degiskeni �zerinde daha iyi i�lem yapabilmek ad�na data.frame e d�n��t�r�ld�.
sonuc=as.data.frame(sonuc)

#s�tun ismi atand�.
colnames(sonuc)=c("PassengerId")

#sonucta Survived de�i�keni olu�turularak tahmin sonu�lar� buraya aktar�ld�

sonuc$Survived=tahminler

#verimizde tahmin edilemeyen de�erler varm� kontrol etmek i�in describe fonksiyonu kullan�l�r. 
describe(sonuc)

#verilerin excele aktar�lmas�
write.csv(sonuc,"C:/Users/Meltem/Desktop/sonuc.csv",row.names = F)






